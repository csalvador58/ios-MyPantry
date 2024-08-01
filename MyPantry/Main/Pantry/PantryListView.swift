//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import SwiftUI
import Models

struct PantryListView: View {
    @State private var vm: PantryListViewModel
    @State private var sharingPantry: Pantry?
    @State private var isShowingShareSheet = false
    
    init(viewModel: PantryListViewModel = PantryListViewModel()) {
        _vm = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading pantries...")
                } else if let error = vm.error {
                    Text("Error: \(error)")
                } else if vm.pantries.isEmpty {
                    Text("No pantries found. Create one to get started!")
                } else {
                    List(vm.pantries) { pantry in
                        HStack {
                            Text(pantry.name)
                            Spacer()
                            if pantry.isShared {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Button("Share") {
                                    sharingPantry = pantry
                                    isShowingShareSheet = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Pantries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // TODO: Action to create a new pantry
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
        .task {
            await vm.loadPantries()
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let pantry = sharingPantry {
//                SharePantryView(pantry: pantry)
                Text("SharePantryView")
            }
        }
    }
}

#Preview("PantryListView") {
    let mockViewModel = PantryListViewModel()
    mockViewModel.pantries = [
        Pantry(id: "1", name: "Kitchen", ownerId: "user1", isShared: false),
        Pantry(id: "2", name: "Basement", ownerId: "user1", isShared: true),
        Pantry(id: "3", name: "Garage", ownerId: "user1", isShared: false)
    ]
    return PantryListView(viewModel: mockViewModel)
}

#Preview("PantryListView - Loading") {
    let mockViewModel = PantryListViewModel()
    mockViewModel.isLoading = true
    return PantryListView(viewModel: mockViewModel)
}

#Preview("PantryListView - Error") {
    let mockViewModel = PantryListViewModel()
    mockViewModel.error = "Failed to load pantries"
    return PantryListView(viewModel: mockViewModel)
}

#Preview("PantryListView - Empty") {
    let mockViewModel = PantryListViewModel()
    mockViewModel.pantries = []
    return PantryListView(viewModel: mockViewModel)
}
