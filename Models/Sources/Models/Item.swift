//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Foundation

public enum ItemStatus: Int, Codable, Identifiable, CaseIterable {
    case inStock, outOfStock, lowStock, inactive

    public var id: Self { self }

    public var descr: String {
        switch self {
        case .inStock: return "In Stock"
        case .outOfStock: return "Out Of Stock"
        case .lowStock: return "Low Stock"
        case .inactive: return "Inactive"
        }
    }
}

public struct Item: Identifiable, Equatable, Hashable {
    public static let recordType = CKRecord.RecordType("Item")

    public let id: CKRecord.ID?
    public let name: String
    public let quantity: Int
    public let quantityDesired: Int?
    public let barcode: String?
    public let favorite: Bool
    public let customContent1: String?
    public let customContent2: String?
    public let customContent3: String?
    public let dateAdded: Date
    public let dateLastUpdated: Date
    public let expireDate: Date?
    public let note: String?
    public let pantryId: String
    public let status: ItemStatus

    public enum CodingKeys: String {
        case id, name, quantity, quantityDesired, barcode, favorite, customContent1, customContent2, customContent3, dateAdded, dateLastUpdated, expireDate, note, pantryId, status
    }

    public init(
        id: CKRecord.ID? = nil,
        name: String,
        quantity: Int,
        quantityDesired: Int? = nil,
        barcode: String? = nil,
        favorite: Bool,
        customContent1: String? = nil,
        customContent2: String? = nil,
        customContent3: String? = nil,
        dateAdded: Date,
        dateLastUpdated: Date,
        expireDate: Date? = nil,
        note: String? = nil,
        pantryId: String,
        status: ItemStatus
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.quantityDesired = quantityDesired
        self.barcode = barcode
        self.favorite = favorite
        self.customContent1 = customContent1
        self.customContent2 = customContent2
        self.customContent3 = customContent3
        self.dateAdded = dateAdded
        self.dateLastUpdated = dateLastUpdated
        self.expireDate = expireDate
        self.note = note
        self.pantryId = pantryId
        self.status = status
    }

    public func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Item.recordType)
        record[CodingKeys.name.rawValue] = name
        record[CodingKeys.quantity.rawValue] = quantity
        record[CodingKeys.quantityDesired.rawValue] = quantityDesired
        record[CodingKeys.barcode.rawValue] = barcode
        record[CodingKeys.favorite.rawValue] = favorite
        record[CodingKeys.customContent1.rawValue] = customContent1
        record[CodingKeys.customContent2.rawValue] = customContent2
        record[CodingKeys.customContent3.rawValue] = customContent3
        record[CodingKeys.dateAdded.rawValue] = dateAdded
        record[CodingKeys.dateLastUpdated.rawValue] = dateLastUpdated
        record[CodingKeys.expireDate.rawValue] = expireDate
        record[CodingKeys.note.rawValue] = note
        record[CodingKeys.pantryId.rawValue] = pantryId
        record[CodingKeys.status.rawValue] = status.rawValue
        return record
    }

    public static func fromRecord(_ record: CKRecord) -> Item? {
        guard record.recordType == Item.recordType,
              let name = record[CodingKeys.name.rawValue] as? String,
              let quantity = record[CodingKeys.quantity.rawValue] as? Int,
              let favorite = record[CodingKeys.favorite.rawValue] as? Bool,
              let dateAdded = record[CodingKeys.dateAdded.rawValue] as? Date,
              let dateLastUpdated = record[CodingKeys.dateLastUpdated.rawValue] as? Date,
              let statusRawValue = record[CodingKeys.status.rawValue] as? Int,
              let pantryId = record[CodingKeys.pantryId.rawValue] as? String,
              let status = ItemStatus(rawValue: statusRawValue)
        else { return nil }

        return Item(
            id: record.recordID,
            name: name,
            quantity: quantity,
            quantityDesired: record[CodingKeys.quantityDesired.rawValue] as? Int,
            barcode: record[CodingKeys.barcode.rawValue] as? String,
            favorite: favorite,
            customContent1: record[CodingKeys.customContent1.rawValue] as? String,
            customContent2: record[CodingKeys.customContent2.rawValue] as? String,
            customContent3: record[CodingKeys.customContent3.rawValue] as? String,
            dateAdded: dateAdded,
            dateLastUpdated: dateLastUpdated,
            expireDate: record[CodingKeys.expireDate.rawValue] as? Date,
            note: record[CodingKeys.note.rawValue] as? String,
            pantryId: pantryId,
            status: status
        )
    }
}

public extension Item {
    func recordDictionary() -> [CodingKeys: CKRecordValue?] {
        return [
            .name: name as CKRecordValue?,
            .quantity: quantity as CKRecordValue?,
            .quantityDesired: quantityDesired as CKRecordValue?,
            .barcode: barcode as CKRecordValue?,
            .favorite: favorite as CKRecordValue?,
            .customContent1: customContent1 as CKRecordValue?,
            .customContent2: customContent2 as CKRecordValue?,
            .customContent3: customContent3 as CKRecordValue?,
            .dateAdded: dateAdded as CKRecordValue?,
            .dateLastUpdated: dateLastUpdated as CKRecordValue?,
            .expireDate: expireDate as CKRecordValue?,
            .note: note as CKRecordValue?,
            .pantryId: pantryId as CKRecordValue?,
            .status: status.rawValue as CKRecordValue?,
        ]
    }
}
