//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import SwiftUI

@MainActor
@Observable class WelcomeViewModel {
    
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    
    init() {
        getiCloudStatus()
    }
    
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] returnedStatus, _ in
            guard let self = self else { return }
            Task { @MainActor in
                switch returnedStatus {
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
                default:
                    self.error = CloudKitError.iCloudAccountOtherUnknown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountUnknown
        case iCloudAccountRestricted
        case iCloudAccountNotFound
        case iCloudAccountUnavailable
        case iCloudAccountOtherUnknown
    }
    
    func getiCloudUser() {
        
    }
}

@MainActor
struct WelcomeView: View {
    @State var viewModel = WelcomeViewModel()
    
    var body: some View {
        Text("IS SIGNED IN: \(viewModel.isSignedInToiCloud.description.uppercased())")
        Text("Error: \(viewModel.error)")
    }
}

#Preview {
    WelcomeView()
}
