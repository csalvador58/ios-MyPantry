//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation
import CloudKit

public struct Pantry: Identifiable, Equatable, Hashable {
    public var id: CKRecord.ID?
    public var name: String
    public var ownerId: String
    
    public static let type = "Pantry"
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case ownerId
    }
}

extension Pantry {
    public init?(record: CKRecord) {
        guard
            let name = record[Pantry.CodingKeys.name.rawValue] as? String,
            let ownerId = record[Pantry.CodingKeys.ownerId.rawValue] as? String
        else {
            return nil
        }
        
        self.init(
            id: record.recordID,
            name: name,
            ownerId: ownerId
        )
    }
}

extension Pantry {
    public var record: CKRecord {
        let record = CKRecord(recordType: Pantry.type)
        record[Pantry.CodingKeys.name.rawValue] = name as CKRecordValue
        record[Pantry.CodingKeys.ownerId.rawValue] = ownerId as CKRecordValue
        return record
    }
}

extension Pantry {
    public func recordDictionary() -> [CodingKeys: CKRecordValue?] {
        return [
            .name: name as CKRecordValue?,
            .ownerId: ownerId as CKRecordValue?
        ]
    }
}
