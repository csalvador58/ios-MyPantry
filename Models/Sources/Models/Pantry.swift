//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Foundation

public struct Pantry: Identifiable, Equatable, Hashable {
//    public static let recordType = "Pantry"
//    public static let zoneId = CKRecordZone.ID(zoneName: "PantryZone")

    public let id: String
    public let name: String
    public let ownerId: String
    public let shareReference: String?
    public let isShared: Bool

    public enum CodingKeys: String {
        case name, ownerId, shareReference, isShared
    }

    public init(
        id: String = UUID().uuidString,
        name: String,
        ownerId: String,
        shareReference: String? = nil,
        isShared: Bool = false
    ) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.shareReference = shareReference
        self.isShared = isShared
    }
}
