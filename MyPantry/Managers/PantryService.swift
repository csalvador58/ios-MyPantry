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
    func fetchPantry() async throws -> [Pantry]
    func addPantry(_ pantry: Pantry, owner: String) async throws -> Pantry
    func updatePantry(_ pantry: Pantry) async throws -> Pantry
    func deletePantry(_ pantry: Pantry) async throws
}

struct PantryService: PantryServiceType {
    let ckDB: CKDatabase

    init() {
        ckDB = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
    }

    func fetchPantry() async throws -> [Pantry] {
        let query = CKQuery(recordType: Pantry.type, predicate: NSPredicate(value: true))

        let (matchResults, _) = try await ckDB.records(matching: query)
        let records = matchResults.compactMap { try? $0.1.get() }

        return records.compactMap { Pantry(record: $0) }
    }

    func addPantry(_ pantry: Pantry, owner: String) async throws -> Pantry {
        var newPantry = pantry
        newPantry.ownerId = owner
        let record = newPantry.record
        let savedRecord = try await ckDB.save(record)
        guard let savedPantry = Pantry(record: savedRecord) else {
            throw PantryServiceError.failedToSavePantry
        }

        return savedPantry
    }

    func updatePantry(_ pantry: Pantry) async throws -> Pantry {
        guard let id = pantry.id else {
            throw PantryServiceError.invalidPantryId
        }

        let record = try await ckDB.record(for: id)
        record[Pantry.CodingKeys.name.rawValue] = pantry.name as CKRecordValue
        record[Pantry.CodingKeys.ownerId.rawValue] = pantry.ownerId as CKRecordValue

        let updatedRecord = try await ckDB.save(record)
        guard let updatedPantry = Pantry(record: updatedRecord) else {
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
