//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Foundation

public struct Item: Identifiable, Equatable, Hashable {
    public let id: String
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
        id: String = UUID().uuidString,
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
}

public extension Item {
    enum ItemStatus: Int, Codable, Identifiable, CaseIterable {
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
}
