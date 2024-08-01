//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Models

protocol CloudKitConvertible {
    associatedtype ModelType
    static var recordType: CKRecord.RecordType { get }
    static func fromRecord(_ record: CKRecord) -> ModelType?
    static func toRecord(_ item: ModelType) -> CKRecord
}

struct PantryConverter: CloudKitConvertible {
    typealias ModelType = Pantry

    static var recordType: CKRecord.RecordType { "Pantry" }

    static func fromRecord(_ record: CKRecord) -> Pantry? {
        guard record.recordType == recordType,
              let name = record[Pantry.CodingKeys.name.rawValue] as? String,
              let ownerId = record[Pantry.CodingKeys.ownerId.rawValue] as? String,
              let isShared = record[Pantry.CodingKeys.isShared.rawValue] as? Bool
        else { return nil }

        return Pantry(
            id: record.recordID.recordName,
            name: name,
            ownerId: ownerId,
            shareReferenceId: record[Pantry.CodingKeys.shareReferenceId.rawValue] as? String,
            isShared: isShared
        )
    }

    static func toRecord(_ pantry: Pantry) -> CKRecord {
        let recordID = CKRecord.ID(recordName: pantry.id)
        let record = CKRecord(recordType: recordType, recordID: recordID)

        record[Pantry.CodingKeys.name.rawValue] = pantry.name
        record[Pantry.CodingKeys.ownerId.rawValue] = pantry.ownerId
        record[Pantry.CodingKeys.shareReferenceId.rawValue] = pantry.shareReferenceId
        record[Pantry.CodingKeys.isShared.rawValue] = pantry.isShared

        return record
    }
}

extension PantryConverter {
    static func setFields(for record: CKRecord, from pantry: Pantry) {
        record[Pantry.CodingKeys.name.rawValue] = pantry.name
        record[Pantry.CodingKeys.ownerId.rawValue] = pantry.ownerId
        record[Pantry.CodingKeys.shareReferenceId.rawValue] = pantry.shareReferenceId
        record[Pantry.CodingKeys.isShared.rawValue] = pantry.isShared
        record[Pantry.CodingKeys.zoneId.rawValue] = pantry.zoneId
    }
}


struct ItemConverter: CloudKitConvertible {
    typealias ModelType = Item

    static var recordType: CKRecord.RecordType { "Item" }

    static func fromRecord(_ record: CKRecord) -> Item? {
        guard record.recordType == recordType,
              let name = record[Item.CodingKeys.name.rawValue] as? String,
              let quantity = record[Item.CodingKeys.quantity.rawValue] as? Int,
              let favorite = record[Item.CodingKeys.favorite.rawValue] as? Bool,
              let dateAdded = record[Item.CodingKeys.dateAdded.rawValue] as? Date,
              let dateLastUpdated = record[Item.CodingKeys.dateLastUpdated.rawValue] as? Date,
              let statusRawValue = record[Item.CodingKeys.status.rawValue] as? Int,
              let pantryId = record[Item.CodingKeys.pantryId.rawValue] as? String,
              let status = Item.ItemStatus(rawValue: statusRawValue)
        else { return nil }

        return Item(
            id: record.recordID.recordName,
            name: name,
            quantity: quantity,
            quantityDesired: record[Item.CodingKeys.quantityDesired.rawValue] as? Int,
            barcode: record[Item.CodingKeys.barcode.rawValue] as? String,
            favorite: favorite,
            customContent1: record[Item.CodingKeys.customContent1.rawValue] as? String,
            customContent2: record[Item.CodingKeys.customContent2.rawValue] as? String,
            customContent3: record[Item.CodingKeys.customContent3.rawValue] as? String,
            dateAdded: dateAdded,
            dateLastUpdated: dateLastUpdated,
            expireDate: record[Item.CodingKeys.expireDate.rawValue] as? Date,
            note: record[Item.CodingKeys.note.rawValue] as? String,
            pantryId: pantryId,
            status: status
        )
    }

    static func toRecord(_ item: Item) -> CKRecord {
        let recordID = CKRecord.ID(recordName: item.id)
        let record = CKRecord(recordType: recordType, recordID: recordID)

        record[Item.CodingKeys.name.rawValue] = item.name
        record[Item.CodingKeys.quantity.rawValue] = item.quantity
        record[Item.CodingKeys.quantityDesired.rawValue] = item.quantityDesired
        record[Item.CodingKeys.barcode.rawValue] = item.barcode
        record[Item.CodingKeys.favorite.rawValue] = item.favorite
        record[Item.CodingKeys.customContent1.rawValue] = item.customContent1
        record[Item.CodingKeys.customContent2.rawValue] = item.customContent2
        record[Item.CodingKeys.customContent3.rawValue] = item.customContent3
        record[Item.CodingKeys.dateAdded.rawValue] = item.dateAdded
        record[Item.CodingKeys.dateLastUpdated.rawValue] = item.dateLastUpdated
        record[Item.CodingKeys.expireDate.rawValue] = item.expireDate
        record[Item.CodingKeys.note.rawValue] = item.note
        record[Item.CodingKeys.pantryId.rawValue] = item.pantryId
        record[Item.CodingKeys.status.rawValue] = item.status.rawValue

        return record
    }
}
