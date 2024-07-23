//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import SwiftUI

@MainActor
struct WelcomeView: View {
    @State private var viewModel = WelcomeViewModel()

    var body: some View {
        VStack {
            if viewModel.isSignedInToiCloud {
                if let userName = viewModel.userName {
                    Text("Welcome, \(userName)!")
                } else {
                    Text("Welcome, iCloud user!")
                }
            } else {
                Link("Click to Sign In to your iCloud Account", destination: URL(string: "App-Prefs:root=CASTLE")!)
            }

            if !viewModel.error.isEmpty {
                Text("Error: \(viewModel.error)")
                    .foregroundStyle(Color.red)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
