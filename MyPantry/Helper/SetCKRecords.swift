//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation
import Models
import CloudKit

typealias CKRecordValue = __CKRecordObjCValue

protocol CodingKeysProtocol: RawRepresentable where RawValue == String {}

extension Item.CodingKeys: CodingKeysProtocol {}
extension Pantry.CodingKeys: CodingKeysProtocol {}

enum RecordValueError: Error {
    case incompatibleType
}

func setRecordValue<K: CodingKeysProtocol>(_ value: CKRecordValue?, for key: K, in record: CKRecord) -> Result<Void, RecordValueError> {
    if let value = value {
        record[key.rawValue] = value
        return .success(())
    } else {
        // If the value is nil, we're not setting anything, which we consider a success
        return .success(())
    }
}
