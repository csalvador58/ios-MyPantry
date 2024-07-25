import CloudKit
import Models
import SwiftUI

@MainActor
@Observable class AppViewModel {
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    var userName: String?
    var isLoading: Bool = false
    var myPantries: [Pantry] = []
    var showCreatePantryView: Bool = false

    init() {
        Task {
            await getiCloudStatus()
            if isSignedInToiCloud {
                await getiCloudUser()
            }
        }
    }

    func getiCloudStatus() async {
        do {
            let accountStatus = try await CKContainer.default().accountStatus()
            switch accountStatus {
            case .available:
                self.isSignedInToiCloud = true
            case .couldNotDetermine:
                self.error = CloudKitError.iCloudAccountUnknown.rawValue
            case .restricted:
                self.error = CloudKitError.iCloudAccountRestricted.rawValue
            case .noAccount:
                self.error = CloudKitError.iCloudAccountNotFound.rawValue
            case .temporarilyUnavailable:
                self.error = CloudKitError.iCloudAccountUnavailable.rawValue
            @unknown default:
                self.error = CloudKitError.iCloudAccountOtherUnknown.rawValue
            }
        } catch {
            self.error = "An error occurred: \(error.localizedDescription)"
        }
    }

    func getiCloudUser() async {
        do {
            let container = CKContainer.default()
            let recordID = try await container.userRecordID()
            let record = try await container.publicCloudDatabase.record(for: recordID)
            if let name = record["giverName"] as? String {
                self.userName = name
            }
        } catch {
            self.error = "Failed to fetch user: \(error.localizedDescription)"
        }
    }

    enum CloudKitError: String, LocalizedError {
        case iCloudAccountUnknown
        case iCloudAccountRestricted
        case iCloudAccountNotFound
        case iCloudAccountUnavailable
        case iCloudAccountOtherUnknown
    }

    func getiCloudUser() {}
}

class MockAppViewModel: AppViewModel {
    init(isIcloudEnabled: Bool) {
        super.init()
        self.isSignedInToiCloud = isIcloudEnabled
        if isIcloudEnabled {
            self.userName = "Mock User"
        }
    }

    override func getiCloudStatus() async {
        if isSignedInToiCloud {
            _ = CKAccountStatus.available
            self.error = ""
        } else {
            _ = CKAccountStatus.noAccount
            self.error = CloudKitError.iCloudAccountNotFound.rawValue
        }
    }

    override func getiCloudUser() async {
        if isSignedInToiCloud {
            self.userName = "Mock User"
        } else {
            self.error = "iCloud account not available in mock."
        }
    }
}
