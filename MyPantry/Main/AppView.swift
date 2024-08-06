//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI

@MainActor
struct AppView: View {
    @Bindable private var vm: AppViewModel
    
    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    @AppStorage("cachedICloudUserId") private var cachedICloudUserId: String?
    
    init(viewModel: AppViewModel? = nil) {
        _vm = Bindable(viewModel ?? AppViewModel(cloudKitService: CloudKitService(containerIdentifier: Config.containerIdentifier)))
    }
    
    var body: some View {
        Group {
            if vm.isSignedInToiCloud {
                if let pantryId = selectedPantryId, !pantryId.isEmpty {
                    mainView
                } else {
                    InitialPantryView()

                }
            } else {
                signInView
            }
        }
        .task {
            await vm.getiCloudStatus()
        }
        .onAppear {
            vm.cachedICloudUserIdBinding = Binding(
                get: { cachedICloudUserId },
                set: { cachedICloudUserId = $0 }
            )
        }
    }
    
    private var mainView: some View {
        TabView {
            Text("Home View")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            PantryView()
                .tabItem {
                    Label("My Pantry", systemImage: "door.french.open")
                }
            Text("Add Item VIew")
                .tabItem {
                    Label("Add Item", systemImage: "plus.app.fill")
                }
            Text("Settings View")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .withTheme()
    }
    
    private var signInView: some View {
        VStack(spacing: 20) {
            Text("Welcome to My Pantry")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Please sign in to your iCloud account to use this app.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // Open iOS Settings app
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }, label: {
                Text("Sign In to iCloud")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            
            if !vm.error.isEmpty {
                Text(vm.error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        //    private var signInView: some View {
        //        VStack {
        //            Link("Click to Sign In to your iCloud Account", destination: URL(string: "App-Prefs:root=CASTLE")!)
        //
        //            if !viewModel.error.isEmpty {
        //                Text("Error: \(viewModel.error)")
        //                    .foregroundStyle(Color.red)
        //            }
        //        }
        //    }
    }
}

#Preview("iCloud Enabled") {
    let viewModel = MockAppViewModel()
    viewModel.setup(isIcloudEnabled: true)
    return AppView(viewModel: viewModel)
}

#Preview("iCloud Not Enabled") {
    let viewModel = MockAppViewModel()
    viewModel.setup(isIcloudEnabled: false, error: "iCloud account not found")
    return AppView(viewModel: viewModel)
}
