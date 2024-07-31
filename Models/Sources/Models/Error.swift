//
//  Error.swift
//
//
//  Created by Salvador on 7/17/24.
//

import Foundation

public enum ItemManagerError: Error {
    case noPantryIdSet
    case itemHasNoId
    case failedToSaveItem
    case failedToUpdateItem
    case failedToSetRecordValues
}

public enum PantryServiceError: Error {
    case failedToSavePantry
    case failedToUpdatePantry
    case invalidPantryId
    case failedToSetRecordValues
    case failedToCreateSharedPantry
    case failedToFetchPantry
    case invalidPantryZone
    case failedToFetchShare
    case userNotFound
}
