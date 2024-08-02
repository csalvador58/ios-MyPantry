import Models
import SwiftUI

@MainActor
@Observable class AppViewModel: @unchecked Sendable {
    nonisolated var ckService: CloudKitServiceType
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    var userRecordId: String?
    var cachedICloudUserIdBinding: Binding<String?>?
    
    nonisolated init(cloudKitService: CloudKitServiceType = CloudKitService()) {
        self.ckService = cloudKitService
    }
    
    func getiCloudStatus() async {
        do {
            try await ckService.verifyiCloudAvailability()
            isSignedInToiCloud = true
            let fetchedUserRecordId = try await ckService.fetchUserRecordID()
            userRecordId = fetchedUserRecordId
            cachedICloudUserIdBinding?.wrappedValue = fetchedUserRecordId
        } catch {
            self.error = error.localizedDescription
            isSignedInToiCloud = false
        }
    }
}

class MockAppViewModel: AppViewModel {
    override init(cloudKitService: CloudKitServiceType = MockCloudKitService()) {
        super.init(cloudKitService: cloudKitService)
    }
    
    func setup(isIcloudEnabled: Bool, error: String = "") {
        self.isSignedInToiCloud = isIcloudEnabled
        self.error = error
        if isIcloudEnabled {
            self.userRecordId = "mock-user-id"
        }
    }
    
    override func getiCloudStatus() async {
        // The status is already set in setup, so we don't need to do anything here
    }
}
