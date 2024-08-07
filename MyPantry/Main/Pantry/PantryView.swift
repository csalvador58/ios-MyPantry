////
////  My Pantry
////  Created by Chris Salvador on 2024
////  SWD Creative Labs
////
import SwiftUI
import Models
import CloudKit
import os

@MainActor
struct PantryView: View {
    @Environment(\.pantryService) private var pantryService
    @Bindable private var vm: PantryViewModel
    
    init(viewModel: PantryViewModel? = nil) {
        _vm = Bindable(viewModel ?? PantryViewModel(pantryService: PantryService(containerIdentifier: Config.containerIdentifier)))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading pantries...")
                } else if vm.createdPantries.isEmpty && vm.invitedPantries.isEmpty {
                    Text("No pantries found. Create one to get started!")
                } else {
                    List {
                        Section("Created") {
                            ForEach(vm.createdPantries) { pantry in
                                PantryRowView(pantry: pantry, vm: vm) {
                                    vm.selectedPantry = pantry
                                    Task {
                                        await vm.initiateSharing(for: pantry)
                                    }
                                }
                            }
                        }
                        
//                        Section("Invited") {
//                            ForEach(vm.invitedPantries) { pantry in
//                                PantryRowView(pantry: pantry, vm: vm) {
//                                    vm.selectedPantry = pantry
//                                }
//                            }
//                        }
                    }
                }
            }
            .navigationTitle("My Pantries")
            .task {
                await vm.loadPantries()
            }
            .sheet(isPresented: $vm.isSharePresented) {
                if let sharingInfo = vm.sharingInfo {
                    CloudSharingView(
                        share: sharingInfo.share,
                        container: CKContainer(
                            identifier: Config.containerIdentifier
                        ),
                        pantry: sharingInfo.pantry
                    )
                }
            }
            .alert("Error", isPresented: .constant(vm.error != nil), actions: {
                Button("OK") { vm.error = nil }
            }, message: {
                Text(vm.error ?? "An unknown error occurred")
            })
            .sheet(isPresented: $vm.showCreatePantrySheet) {
                CreatePantryView { newPantry in
                    Task {
                        await vm.loadPantries()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        vm.showCreatePantrySheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
    }
}

struct PantryRowView: View {
    let pantry: Pantry
    let vm: PantryViewModel
    @AppStorage("selectedPantryId") private var selectedPantryId: String?
    
    init(pantry: Pantry, vm: PantryViewModel) {
        self.pantry = pantry
        self.vm = vm
    }
    
    var body: some View {
        HStack {
            Text(pantry.name)
                .foregroundStyle(pantry.id == selectedPantryId ? .primaryColor : .adaptiveTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            if pantry.isShared {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedPantryId = pantry.id
        }
    }
}

//    private func pantryRow(_ pantry: Pantry) -> some View {
//        HStack {
//            Text(pantry.name)
//                .foregroundStyle(pantry.id == selectedPantryId ? .primaryColor : .adaptiveTextColor)
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//            if pantry.isShared {
//                Image(systemName: "person.2.fill")
//                    .foregroundColor(.green)
//            } else {
//                Button(action: {
//                    logger.info("Share button tapped for Pantry: \(pantry.id)")
//                    sharingPantry = pantry
//                }, label: {
//                    Text("Share")
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                })
//                .buttonStyle(PlainButtonStyle())
//            }
//        }
//        .contentShape(Rectangle())
//        .onTapGesture {
//            logger.info("Pantry selected: \(pantry.id)")
//            selectedPantryId = pantry.id
//        }
//    }
//}
//
//#Preview("PantryListView - With Pantries") {
//    let mockService = MockPantryService(
//        privatePantries: [
//            Pantry(id: "1", name: "Kitchen", ownerId: "user1", isShared: false),
//            Pantry(id: "3", name: "Garage", ownerId: "user1", isShared: false)
//        ],
//        sharedPantries: [
//            Pantry(id: "2", name: "Basement", ownerId: "user1", isShared: true)
//        ]
//    )
//    return PantryView()
//        .environment(\.pantryService, mockService)
//        .withTheme()
//}
//
//#Preview("PantryView - Loading") {
//    let mockService = MockPantryService(isLoading: true)
//    return PantryView()
//        .environment(\.pantryService, mockService)
//        .withTheme()
//}
//
//#Preview("PantryView - Error") {
//    let mockService = MockPantryService(error: "Failed to load pantries")
//    return PantryView()
//        .environment(\.pantryService, mockService)
//        .withTheme()
//}
//
//#Preview("PantryView - Empty") {
//    let mockService = MockPantryService()
//    return PantryView()
//        .environment(\.pantryService, mockService)
//        .withTheme()
//}
