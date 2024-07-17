//
//  File.swift
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
}
