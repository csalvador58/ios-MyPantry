//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation

public struct Pantry: Identifiable, Equatable, Hashable {
    public static let recordType = "Pantry"
    public static let zoneId = CKRecordZone.ID(zoneName: "PantryZone")

    public let id: CKRecord.ID
    public var name: String
    public let ownerId: String
    public var shareReference: CKRecord.Reference?
    public var isShared: Bool

    public enum CodingKeys: String {
        case name, ownerId, shareReference, isShared
    }

    public init(
        id: CKRecord.ID = CKRecord.ID(zoneID: Pantry.zoneId),
        name: String,
        ownerId: String,
        shareReference: CKRecord.Reference? = nil,
        isShared: Bool = false
    ) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.shareReference = shareReference
        self.isShared = isShared
    }

    public func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Pantry.recordType, recordID: id)
        record[CodingKeys.name.rawValue] = name
        record[CodingKeys.ownerId.rawValue] = ownerId
        record[CodingKeys.shareReference.rawValue] = shareReference
        record[CodingKeys.isShared.rawValue] = isShared
        return record
    }

    public static func fromRecord(_ record: CKRecord) -> Pantry? {
        guard record.recordType == Pantry.recordType,
              let name = record[CodingKeys.name.rawValue] as? String,
              let ownerId = record[CodingKeys.ownerId.rawValue] as? String,
              let isShared = record[CodingKeys.isShared.rawValue] as? Bool
        else { return nil }

        return Pantry(
            id: record.recordID,
            name: name,
            ownerId: ownerId,
            shareReference: record[CodingKeys.shareReference.rawValue] as? CKRecord.Reference,
            isShared: isShared
        )
    }
}
