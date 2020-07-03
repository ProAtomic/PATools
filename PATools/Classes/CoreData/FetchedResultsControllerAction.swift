//
//  FetchedResultsControllerAction.swift
//  Pods
//
//  Created by Guillermo Andrés Sáenz Urday on 5/11/20.
//

import Foundation

public enum FetchedResultsControllerAction: Equatable {
    case none
    case willChangeContent
    case didChangeObject(indexPath: IndexPath?, type: FetchedResultsControllerActionType, newIndexPath: IndexPath?)
    case didChangeSection(sectionIndex: Int, type: FetchedResultsControllerActionType)
    case didChangeContent
}

public enum FetchedResultsControllerActionType : Equatable {
    case insert
    case delete
    case move
    case update
}
