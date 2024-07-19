//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation
import Models
import SwiftUI

struct PrivateItemManagerKey: EnvironmentKey {
    static let defaultValue = ItemManager(databaseType: .privateDB)
}

struct SharedItemManagerKey: EnvironmentKey {
    static let defaultValue = ItemManager(databaseType: .sharedDB)
}

extension EnvironmentValues {
    var privateItemManager: ItemManager {
        get { self[PrivateItemManagerKey.self] }
        set { self[PrivateItemManagerKey.self] = newValue }
    }

    var sharedItemManager: ItemManager {
        get { self[SharedItemManagerKey.self] }
        set { self[SharedItemManagerKey.self] = newValue }
    }
}

protocol ItemManagerType {
    /// Fetches a collection of items, filtered by a pantry id.
    /// - Parameters:
    ///   - pantryId: The id of a pantry collection.
    /// - Returns: An array of fetched `Item` objects.
    func fetchItems(for pantryId: String) async throws -> [Item]

    /// Adds a new item to the specified pantry.
    /// - Parameters:
    ///   - item: The `Item` object to add.
    ///   - pantryId: The id of the pantry to which the item will be added.
    /// - Returns: An updated array of `Item` objects after the addition.
    func addItem(_ item: Item, to pantryId: String) async throws -> Item

    /// Updates an existing item in the specified pantry.
    /// - Parameters:
    ///   - item: The `Item` object to update.
    ///   - pantryId: The id of the pantry containing the item to update.
    /// - Returns: An updated array of `Item` objects after the update.
    func updateItem(_ item: Item, in pantryId: String) async throws -> Item

    /// Deletes an existing item from the specified pantry.
    /// - Parameters:
    ///   - item: The `Item` object to delete.
    ///   - pantryId: The id of the pantry containing the item to delete.
    /// - Returns: An updated array of `Item` objects after the deletion.
    func deleteItem(_ item: Item, from pantryId: String) async throws
}

struct ItemManager: ItemManagerType {
    let db: CKDatabase

    init(databaseType: DatabaseType) {
        switch databaseType {
        case .privateDB:
            db = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
        case .sharedDB:
            db = CKContainer(identifier: Config.containerIdentifier).sharedCloudDatabase
        }
    }

    func fetchItems(for pantryId: String) async throws -> [Item] {
        let predicate = NSPredicate(format: "pantryId == %@", pantryId)
        let query = CKQuery(recordType: Item.type, predicate: predicate)

        let (matchResults, _) = try await db.records(matching: query)
        let records = matchResults.compactMap { try? $0.1.get() }

        return records.compactMap { Item(record: $0) }
    }

    func addItem(_ item: Item, to pantryId: String) async throws -> Item {
        var newItem = item
        newItem.pantryId = pantryId
        let record = newItem.record
        let savedRecord = try await db.save(record)
        guard let savedItem = Item(record: savedRecord) else {
            throw ItemManagerError.failedToSaveItem
        }

        var items = try await fetchItems(for: pantryId)
        items.append(savedItem)
        return savedItem
    }

    func updateItem(_ item: Item, in _: String) async throws -> Item {
        guard let id = item.id else {
            throw ItemManagerError.itemHasNoId
        }

        // Fetch record of item to update
        let record = try await db.record(for: id)
        // Convert all item inputs into valid CKRecord types
        let results = item.recordDictionary().compactMap { key, value -> Result<Void, RecordValueError>? in
            setRecordValue(value, for: key, in: record)
        }
        // Check for errors, if any, record is not updated in cloudkit
        let failures = results.compactMap { result -> RecordValueError? in
            if case let .failure(error) = result {
                return error
            }
            return nil
        }
        if !failures.isEmpty {
            _ = failures.map { $0.localizedDescription }.joined(separator: "\n")
            throw ItemManagerError.failedToSetRecordValues
        }
        // Update record in cloud kit and verify
        let updatedRecord = try await db.save(record)
        guard let updatedItem = Item(record: updatedRecord) else {
            throw ItemManagerError.failedToUpdateItem
        }

        return updatedItem
    }

    func deleteItem(_ item: Item, from pantryId: String) async throws {
        guard let id = item.id else {
            throw ItemManagerError.itemHasNoId
        }

        try await db.deleteRecord(withID: id)

        var items = try await fetchItems(for: pantryId)
        items.removeAll { $0.id == id }
    }
}
