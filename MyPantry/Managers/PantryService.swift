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
    func fetchOrCreateShare(for pantry: Pantry) async throws -> (CKShare, CKContainer)
    func acceptShare(metadata: CKShare.Metadata) async throws
}

struct PantryService: PantryServiceType {
    let ckDB: CKDatabase
    let cloudKitService: CloudKitServiceType

    init(cloudKitService: CloudKitServiceType = CloudKitService()) {
        self.cloudKitService = cloudKitService
        self.ckDB = CKContainer(identifier: Config.containerIdentifier).privateCloudDatabase
    }

    func fetchPantry(by ownerId: String) async throws -> [Pantry] {
        let predicate = NSPredicate(format: "ownerId == %@", ownerId)
        let query = CKQuery(recordType: PantryConverter.recordType, predicate: predicate)
//        let query = CKQuery(recordType: Pantry.type, predicate: NSPredicate(value: true))

        let (matchResults, _) = try await ckDB.records(matching: query)
        let records = matchResults.compactMap { try? $0.1.get() }

        return records.compactMap { PantryConverter.fromRecord($0) }
    }

    func addPantry(_ pantry: Pantry, ownerId: String) async throws -> Pantry {
        var newPantry = pantry
        if pantry.isShared {
            newPantry = try await cloudKitService.createSharedZone(for: pantry)
        }

        let record = PantryConverter.toRecord(newPantry)
        let saveRecord = try await ckDB.save(record)
        guard let savedPantry = PantryConverter.fromRecord(saveRecord) else {
            throw PantryServiceError.failedToSavePantry
        }

        return savedPantry
    }

    func updatePantry(_ pantry: Pantry) async throws -> Pantry {
        let recordId = pantry.id
        let record = try await ckDB.record(for: CKRecord.ID(recordName: recordId))

        record[Pantry.CodingKeys.name.rawValue] = pantry.name
        record[Pantry.CodingKeys.ownerId.rawValue] = pantry.ownerId
        record[Pantry.CodingKeys.shareReferenceId.rawValue] = pantry.shareReferenceId
        record[Pantry.CodingKeys.isShared.rawValue] = pantry.isShared
        record[Pantry.CodingKeys.zoneId.rawValue] = pantry.zoneId

        let updateRecord = try await ckDB.save(record)

        guard let updatedPantry = PantryConverter.fromRecord(updateRecord) else {
            throw PantryServiceError.failedToUpdatePantry
        }

        return updatedPantry
    }

    func deletePantry(_ pantry: Pantry) async throws {
        let recordId = pantry.id
        try await ckDB.deleteRecord(withID: CKRecord.ID(recordName: recordId))
    }
    
    func fetchOrCreateShare(for pantry: Pantry) async throws -> (CKShare, CKContainer) {
        try await cloudKitService.fetchOrCreateShare(for: pantry)
    }
    
    func acceptShare(metadata: CKShare.Metadata) async throws {
        try await cloudKitService.acceptShare(metadata: metadata)
    }
}
