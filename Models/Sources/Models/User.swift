//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation

public struct User: Identifiable, Equatable, Hashable {
    public var id: CKRecord.ID?
    public var displayName: String
    public var pantryId: String

    public static let type = "User"

    public enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case pantryId
    }
}

public extension User {
    init?(record: CKRecord) {
        guard
            let displayName = record[User.CodingKeys.displayName.rawValue] as? String,
            let pantryId = record[User.CodingKeys.pantryId.rawValue] as? String
        else {
            return nil
        }

        self.init(
            id: record.recordID,
            displayName: displayName,
            pantryId: pantryId
        )
    }
}

public extension User {
    var record: CKRecord {
        let record = CKRecord(recordType: User.type)
        record[User.CodingKeys.displayName.rawValue] = displayName as CKRecordValue
        record[User.CodingKeys.pantryId.rawValue] = pantryId as CKRecordValue
        return record
    }
}
