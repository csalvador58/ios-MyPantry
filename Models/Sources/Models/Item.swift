//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation
import SwiftData

public enum ItemStatus: Int, Codable, Identifiable, CaseIterable {
    case inStock, outOfStock, lowStock, inactive
    
    public var id: Self {
        self
    }
    
    public var descr: String {
        switch self {
        case .inStock:
            "In Stock"
        case .outOfStock:
            "Out Of Stock"
        case .lowStock:
            "Low Stock"
        case .inactive:
            "Inactive"
        }
    }
}

@Model
public class Item {
    public var name: String
    public var quantity: Int
    public var quantityDesired: Int?
    public var barcode: String?
    public var favorite: Bool
    public var customContent1: String
    public var customContent2: String
    public var customContent3: String
    public var dateAdded: Date
    public var dateLastUpdated: Date
    public var expireDate: Date?
    public var note: String?
    public var sharedWith: [String]?
    public var status: ItemStatus
    
    init(
        name: String,
        quantity: Int = 1,
        quantityDesired: Int? = nil,
        barcode: String? = nil,
        favorite: Bool = false,
        customContent1: String = "",
        customContent2: String = "",
        customContent3: String = "",
        dateAdded: Date = Date.now,
        dateLastUpdated: Date = Date.now,
        expireDate: Date? = nil,
        note: String? = nil,
        sharedWith: [String]? = nil,
        status: ItemStatus = .inStock
    ) {
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
        self.sharedWith = sharedWith
        self.status = status
    }
}

