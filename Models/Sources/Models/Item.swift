//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation

public struct Item: Identifiable {
    public var id: String
    public var name: String
    public var quantity: String
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
}

public enum Status: Int, Codable, Identifiable, CaseIterable {
    case inStock, outOfStock, lowStock
    
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
        }
    }
}
