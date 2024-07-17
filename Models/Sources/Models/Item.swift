//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation
import CloudKit

public enum ItemStatus: Int, Codable, Identifiable, CaseIterable {
    case inStock, outOfStock, lowStock, inactive
    
    public var id: Self {
        self
    }
    
    public var descr: String {
        switch self {
        case .inStock:
            return "In Stock"
        case .outOfStock:
            return "Out Of Stock"
        case .lowStock:
            return "Low Stock"
        case .inactive:
            return "Inactive"
        }
    }
}

public struct Item: Identifiable, Equatable, Hashable {
    public var id: CKRecord.ID?
    public var name: String
    public var quantity: Int
    public var quantityDesired: Int?
    public var barcode: String?
    public var favorite: Bool
    public var customContent1: String?
    public var customContent2: String?
    public var customContent3: String?
    public var dateAdded: Date
    public var dateLastUpdated: Date
    public var expireDate: Date?
    public var note: String?
    public var sharedWith: [String]?
    public var status: ItemStatus
    
    public static let type = "Item"
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case quantityDesired
        case barcode
        case favorite
        case customContent1
        case customContent2
        case customContent3
        case dateAdded
        case dateLastUpdated
        case expireDate
        case note
        case sharedWith
        case status
    }
}

extension Item {
    public init?(record: CKRecord) {
        guard
            let name = record[Item.CodingKeys.name.rawValue] as? String,
            let quantity = record[Item.CodingKeys.quantity.rawValue] as? Int,
            let favorite = record[Item.CodingKeys.favorite.rawValue] as? Bool,
            let customContent1 = record[Item.CodingKeys.customContent1.rawValue] as? String,
            let customContent2 = record[Item.CodingKeys.customContent2.rawValue] as? String,
            let customContent3 = record[Item.CodingKeys.customContent3.rawValue] as? String,
            let dateAdded = record[Item.CodingKeys.dateAdded.rawValue] as? Date,
            let dateLastUpdated = record[Item.CodingKeys.dateLastUpdated.rawValue] as? Date,
            let statusRawValue = record[Item.CodingKeys.status.rawValue] as? Int,
            let status = ItemStatus(rawValue: statusRawValue)
        else {
            return nil
        }
        
        self.init(
            id: record.recordID,
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
            sharedWith: record[Item.CodingKeys.sharedWith.rawValue] as? [String],
            status: status
        )
    }
}

extension Item {
    public var record: CKRecord {
        let record = CKRecord(recordType: Item.type)
        record[Item.CodingKeys.name.rawValue] = name as CKRecordValue
        record[Item.CodingKeys.quantity.rawValue] = quantity as CKRecordValue
        if let quantityDesired = quantityDesired {
            record[Item.CodingKeys.quantityDesired.rawValue] = quantityDesired as CKRecordValue
        }
        if let barcode = barcode {
            record[Item.CodingKeys.barcode.rawValue] = barcode as CKRecordValue
        }
        record[Item.CodingKeys.favorite.rawValue] = favorite as CKRecordValue
        if let customContent1 = customContent1 {
            record[Item.CodingKeys.customContent1.rawValue] = customContent1 as CKRecordValue
        }
        if let customContent2 = customContent2 {
            record[Item.CodingKeys.customContent2.rawValue] = customContent2 as CKRecordValue
        }
        if let customContent3 = customContent3 {
            record[Item.CodingKeys.customContent3.rawValue] = customContent3 as CKRecordValue
        }
        record[Item.CodingKeys.dateAdded.rawValue] = dateAdded as CKRecordValue
        record[Item.CodingKeys.dateLastUpdated.rawValue] = dateLastUpdated as CKRecordValue
        if let expireDate = expireDate {
            record[Item.CodingKeys.expireDate.rawValue] = expireDate as CKRecordValue
        }
        if let note = note {
            record[Item.CodingKeys.note.rawValue] = note as CKRecordValue
        }
        if let sharedWith = sharedWith {
            record[Item.CodingKeys.sharedWith.rawValue] = sharedWith as CKRecordValue
        }
        record[Item.CodingKeys.status.rawValue] = status.rawValue as CKRecordValue
        return record
    }
}
