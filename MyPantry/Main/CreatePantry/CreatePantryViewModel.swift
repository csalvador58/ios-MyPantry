//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Models
import SwiftUI

@MainActor
@Observable
class CreatePantryViewModel {
    var name: String = ""
    var isShared: Bool = false

    private let container = CKContainer.default()

    func createPantry() async throws -> Pantry {
        let ownerId = try await container.userRecordID().recordName
        var newPantry = Pantry(name: name, ownerId: ownerId, isShared: isShared)
        let record = newPantry.toRecord()

        if isShared {
            let share = CKShare(rootRecord: record)
            share[CKShare.SystemFieldKey.title] = name

            let (savedRecords, _) = try await container.privateCloudDatabase.modifyRecords(saving: [record, share], deleting: [])

            if case let .success(savedRecord) = savedRecords[record.recordID],
               case let .success(savedShare) = savedRecords[share.recordID]
            {
                newPantry = Pantry.fromRecord(savedRecord)!
                newPantry.shareReference = CKRecord.Reference(record: savedShare, action: .none)
            } else {
                throw NSError(domain: "PantryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to save shared pantry"])
            }
        } else {
            let savedRecord = try await container.privateCloudDatabase.save(record)
            newPantry = Pantry.fromRecord(savedRecord)!
        }

        return newPantry
    }
}

class MockCreatePantryViewModel: CreatePantryViewModel {
    override func createPantry() async throws -> Pantry {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Pantry(id: CKRecord.ID(recordName: "mock"), name: name, ownerId: "mockOwner", isShared: isShared)
    }
}
