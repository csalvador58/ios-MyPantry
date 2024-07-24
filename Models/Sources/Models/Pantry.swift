//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation

public struct Pantry: Identifiable, Equatable, Hashable {
    public static let recordType = CKRecord.RecordType("Pantry")

    public let id: CKRecord.ID?
    public let name: String
    public let ownerId: String

    public enum CodingKeys: String, CodingKey {
        case id, name, ownerId
    }

    public init(
        id: CKRecord.ID? = nil,
        name: String,
        ownerId: String
    ) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
    }

    public func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Pantry.recordType)
        record[CodingKeys.name.rawValue] = name
        record[CodingKeys.ownerId.rawValue] = name
        return record
    }

    public static func fromRecord(_ record: CKRecord) -> Pantry? {
        guard record.recordType == Pantry.recordType,
              let name = record[CodingKeys.name.rawValue] as? String,
              let ownerId = record[CodingKeys.ownerId.rawValue] as? String
        else { return nil }

        return Pantry(
            id: record.recordID,
            name: name,
            ownerId: ownerId
        )
    }
}

public extension Pantry {
    func recordDictionary() -> [CodingKeys: CKRecordValue?] {
        return [
            .name: name as CKRecordValue?,
            .ownerId: ownerId as CKRecordValue?,
        ]
    }
}
