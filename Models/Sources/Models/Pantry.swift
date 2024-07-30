//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import Foundation

public struct Pantry: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let ownerId: String
    public let shareReferenceId: String?
    public let isShared: Bool
    public let zoneId: String?

    public enum CodingKeys: String {
        case name, ownerId, shareReferenceId, isShared, zoneId
    }

    public init(
        id: String = UUID().uuidString,
        name: String,
        ownerId: String,
        shareReferenceId: String? = nil,
        isShared: Bool = false,
        zoneId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.shareReferenceId = shareReferenceId
        self.isShared = isShared
        self.zoneId = zoneId
    }
}

