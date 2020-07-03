//
//  RichFetchRequest.swift
//  Pods
//
//  Created by Guillermo Sáenz on 5/18/20.
//

// Take from: https://www.avanderlee.com/swift/nsfetchedresultscontroller-observe-relationship-changes/

import CoreData

/// An enhanced `NSFetchRequest` that has extra functionality.
public final class RichFetchRequest<ResultType>: NSFetchRequest<NSFetchRequestResult> where ResultType: NSFetchRequestResult {

    /// A set of relationship key paths to observe when using a `RichFetchedResultsController`.
    public var relationshipKeyPathsForRefreshing: Set<String> = []
}
