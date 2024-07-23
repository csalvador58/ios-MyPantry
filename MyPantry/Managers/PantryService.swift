//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation
import Models
import SwiftUI

struct PantryServiceKey: EnvironmentKey {
    static let defaultValue = PantryService()
}

extension EnvironmentValues {
    var pantryService: PantryService {
        get { self[PantryServiceKey.self] }
        set { self[PantryServiceKey.self] = newValue }
    }
}

protocol PantryServiceType {
    func fetchPantry(by ownerId: String) async throws -> [Pantry]
    func addPantry(_ pantry: Pantry, ownerId: String) async throws -> Pantry
    func updatePantry(_ pantry: Pantry) async throws -> Pantry
    func deletePantry(_ pantry: Pantry) async throws
}

struct PantryService: PantryServiceType {
    let ckDB: CKDatabase

    init() {
        ckDB = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
    }

    func fetchPantry(by ownerId: String) async throws -> [Pantry] {
        let predicate = NSPredicate(format: "ownerId == %@", ownerId)
        let query = CKQuery(recordType: Pantry.recordType, predicate: predicate)
//        let query = CKQuery(recordType: Pantry.type, predicate: NSPredicate(value: true))

        let (matchResults, _) = try await ckDB.records(matching: query)
        let records = matchResults.compactMap { try? $0.1.get() }

        return records.compactMap { Pantry.fromRecord($0) }
    }

    func addPantry(_ pantry: Pantry, ownerId: String) async throws -> Pantry {
        let newPantry = Pantry(
            id: pantry.id,
            name: pantry.name,
            ownerId: pantry.ownerId
        )
        
        let record = newPantry.toRecord()
        let saveRecord = try await ckDB.save(record)
        guard let savedPantry = Pantry.fromRecord(saveRecord) else {
            throw PantryServiceError.failedToSavePantry
        }

        return savedPantry
    }

    func updatePantry(_ pantry: Pantry) async throws -> Pantry {
        guard let id = pantry.id else {
            throw PantryServiceError.invalidPantryId
        }

        let record = try await ckDB.record(for: id)
        for (key, value) in pantry.toRecord() {
            record[key] = value
        }
        
        let updateRecord = try await ckDB.save(record)
        
        guard let updatedPantry = Pantry.fromRecord(updateRecord) else {
            throw PantryServiceError.failedToUpdatePantry
        }

        return updatedPantry
    }

    func deletePantry(_ pantry: Pantry) async throws {
        guard let id = pantry.id else {
            throw PantryServiceError.invalidPantryId
        }

        try await ckDB.deleteRecord(withID: id)
    }
}
