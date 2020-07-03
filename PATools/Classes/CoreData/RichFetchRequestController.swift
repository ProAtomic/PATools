//
//  RichFetchRequestController.swift
//  Pods
//
//  Created by Guillermo Sáenz on 5/18/20.
//

// Take from: https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/
// Added support for observing changes in a to many relationship

import Foundation
import CoreData

/// An enhanced `NSFetchedResultsController` that has extra functionality.
public class RichFetchedResultsController<ResultType: NSFetchRequestResult>: NSFetchedResultsController<NSFetchRequestResult> {

    /// The relationship key paths observer that is only initialised if the fetch request has a `relationshipKeyPathsForRefreshing` set.
    private var relationshipKeyPathsObserver: RelationshipKeyPathsObserver<ResultType>?

    public init(fetchRequest: RichFetchRequest<ResultType>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
        super.init(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)

        relationshipKeyPathsObserver = RelationshipKeyPathsObserver<ResultType>(keyPaths: fetchRequest.relationshipKeyPathsForRefreshing, fetchedResultsController: self)
    }

}

/// Describes a relationship key path for a Core Data entity.
fileprivate struct RelationshipKeyPath: Hashable {

    /// The source property name of the relationship entity we're observing.
    let sourcePropertyName: String

    let destinationEntityName: String

    /// The destination property name we're observing
    let destinationPropertyName: String

    /// The inverse property name of this relationship. Can be used to get the affected object IDs.
    let inverseRelationshipKeyPath: String

    public init(keyPath: String, entity: NSEntityDescription, relationships: [String: NSRelationshipDescription]) {
        let splittedKeyPath = keyPath.split(separator: ".")
        sourcePropertyName = String(splittedKeyPath.first!)
        destinationPropertyName = String(splittedKeyPath.last!)

        let relationship = relationships[sourcePropertyName]!
        // If sourcePropertyName & destinationPropertyName are equal that means that we could be trying to observe the changes in a to many relationship
        // We set the destinationEntityName to the same entity
        if sourcePropertyName == destinationPropertyName {
            destinationEntityName = entity.name!
        }else{
            destinationEntityName = relationship.destinationEntity!.name!
        }
        inverseRelationshipKeyPath = relationship.inverseRelationship!.name

        [sourcePropertyName, destinationEntityName, destinationPropertyName].forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }
}

/// Observes relationship key paths and refreshes Core Data objects accordingly once the related managed object context saves.
fileprivate final class RelationshipKeyPathsObserver<ResultType: NSFetchRequestResult>: NSObject {
    private let keyPaths: Set<RelationshipKeyPath>
    private unowned let fetchedResultsController: RichFetchedResultsController<ResultType>

    private var updatedObjectIDs: Set<NSManagedObjectID> = []

    public init?(keyPaths: Set<String>, fetchedResultsController: RichFetchedResultsController<ResultType>) {
        guard !keyPaths.isEmpty else { return nil }

        let entity = fetchedResultsController.fetchRequest.entity!
        let relationships = entity.relationshipsByName
        self.keyPaths = Set(keyPaths.map { keyPath in
            return RelationshipKeyPath(keyPath: keyPath, entity:entity, relationships: relationships)
        })
        self.fetchedResultsController = fetchedResultsController

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChangeNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: fetchedResultsController.managedObjectContext)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: fetchedResultsController.managedObjectContext)
    }
    
    @objc private func contextDidChangeNotification(notification: NSNotification) {
        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        guard let updatedObjectIDs = updatedObjects.updatedObjectIDs(for: keyPaths), !updatedObjectIDs.isEmpty else { return }
        self.updatedObjectIDs = self.updatedObjectIDs.union(updatedObjectIDs)
    }
    
    @objc private func contextDidSaveNotification(notification: NSNotification) {
        guard !updatedObjectIDs.isEmpty else { return }
        guard let fetchedObjects = fetchedResultsController.fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else { return }

        fetchedObjects.forEach { object in
            guard updatedObjectIDs.contains(object.objectID) else { return }
            fetchedResultsController.managedObjectContext.refresh(object, mergeChanges: true)
        }
        updatedObjectIDs.removeAll()
    }
}

fileprivate extension Set where Element: NSManagedObject {

    /// Iterates over the objects and returns the object IDs that matched our observing keyPaths.
    /// - Parameter keyPaths: The keyPaths to observe changes for.
    func updatedObjectIDs(for keyPaths: Set<RelationshipKeyPath>) -> Set<NSManagedObjectID>? {
        var objectIDs: Set<NSManagedObjectID> = []
        forEach { object in
            guard let changedRelationshipKeyPath = object.changedKeyPath(from: keyPaths) else { return }
            
            // If entity name if equal to the changedRelationshipKeyPath.destinationEntityName that means that we are observing changes in a to many relationship
            if object.entity.name == changedRelationshipKeyPath.destinationEntityName {
                objectIDs.insert(object.objectID)
            } else {
                let value = object.value(forKey: changedRelationshipKeyPath.inverseRelationshipKeyPath)
                if let toManyObjects = value as? Set<NSManagedObject> {
                    toManyObjects.forEach {
                        objectIDs.insert($0.objectID)
                    }
                } else if let toOneObject = value as? NSManagedObject {
                    objectIDs.insert(toOneObject.objectID)
                } else {
                    assertionFailure("Invalid relationship observed for keyPath: \(changedRelationshipKeyPath)")
                    return
                }
            }
        }
        
        return objectIDs
    }
}

fileprivate extension NSManagedObject {

    /// Matches the given key paths to the current changes of this `NSManagedObject`.
    /// - Parameter keyPaths: The key paths to match the changes for.
    /// - Returns: The matching relationship key path if found. Otherwise, `nil`.
    func changedKeyPath(from keyPaths: Set<RelationshipKeyPath>) -> RelationshipKeyPath? {
        return keyPaths.first { keyPath -> Bool in
            guard keyPath.destinationEntityName == entity.name! || keyPath.destinationEntityName == entity.superentity?.name else { return false }
            return changedValues().keys.contains(keyPath.destinationPropertyName)
        }
    }
}
