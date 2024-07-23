//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Foundation
import os

protocol CloudKitServiceType {
    func getCKStatus() async throws -> CKAccountStatus
}

struct CloudKitService: CloudKitServiceType {
    
    func getCKStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }
}
