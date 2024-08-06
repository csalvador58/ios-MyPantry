import SwiftUI
import Models
import CloudKit
import os

@MainActor
struct PantryView: View {
    @Environment(\.pantryService) private var pantryService
    @State private var pantries: [Pantry] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var selectedPantry: Pantry?
    @State private var isSharePresented = false
    @State private var sharingInfo: SharingInfo?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PantryView")
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading pantries...")
                } else if pantries.isEmpty {
                    Text("No pantries found. Create one to get started!")
                } else {
                    List(pantries) { pantry in
                        PantryRowView(pantry: pantry) {
                            selectedPantry = pantry
                            if pantry.isShared {
                                Task {
                                    await initiateSharing(for: pantry)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Pantries")
            .task {
                await loadPantries()
            }
            .sheet(isPresented: $isSharePresented) {
                if let sharingInfo = sharingInfo {
                    CloudSharingView(
                        share: sharingInfo.share,
                        container: CKContainer(
                            identifier: Config.containerIdentifier
                        ),
                        pantry: sharingInfo.pantry
                    )
                }
            }
            .alert("Error", isPresented: .constant(error != nil), actions: {
                Button("OK") { error = nil }
            }, message: {
                Text(error ?? "An unknown error occurred")
            })
        }
    }
    
    private func loadPantries() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (privatePantries, sharedPantries) = try await pantryService.fetchPantries()
            pantries = privatePantries + sharedPantries
            logger.info("Successfully loaded \(privatePantries.count) private and \(sharedPantries.count) shared pantries")
        } catch {
            logger.error("Failed to load pantries: \(error.localizedDescription)")
            self.error = error.localizedDescription
        }
    }
    
    private func initiateSharing(for pantry: Pantry) async {
        do {
            print("Initiating sharing for pantry: \(pantry)")
            sharingInfo = try await pantryService.createSharedPantry(pantry)
            isSharePresented = true
            print("Successfully created shared pantry: \(pantry.id)")
        } catch let error as PantryServiceError {
            print("PantryServiceError: \(error)")
            self.error = error.localizedDescription
        } catch {
            print("Unexpected error while creating shared pantry: \(error)")
            self.error = error.localizedDescription
        }
    }
}

struct PantryRowView: View {
    let pantry: Pantry
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(pantry.name)
            Spacer()
            if pantry.isShared {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}


////
////  My Pantry
////  Created by Chris Salvador on 2024
////  SWD Creative Labs
////
//import SwiftUI
//import Models
//import os
//
//@MainActor
//struct PantryView: View {
//    @Environment(\.pantryService) private var pantryService
//    @Bindable private var vm: PantryViewModel
//    @State private var sharingPantry: Pantry?
//    @State private var showCreatePantrySheet = false
//    @AppStorage("selectedPantryId") private var selectedPantryId: String?
//    
//    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PantryView")
//    
//    init(viewModel: PantryViewModel? = nil) {
//        _vm = Bindable(viewModel ?? PantryViewModel(pantryService: PantryService(containerIdentifier: Config.containerIdentifier)))
//    }
//    
//    var body: some View {
//        NavigationStack {
//            Group {
//                if vm.isLoading {
//                    ProgressView("Loading pantries...")
//                } else if vm.privatePantries.isEmpty && vm.sharedPantries.isEmpty {
//                    Text("No pantries found. Create one to get started!")
//                } else {
//                    List {
//                        Section("Created") {
//                            ForEach(vm.privatePantries) { pantry in
//                                pantryRow(pantry)
//                            }
//                        }
//                        
//                        Section("Invited") {
//                            ForEach(vm.sharedPantries) { pantry in
//                                pantryRow(pantry)
//                            }
//                        }
//                    }
//                    .listStyle(PlainListStyle())
//                }
//            }
//            .navigationTitle("My Pantries")
//            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    Button(action: {
//                        showCreatePantrySheet = true
//                        logger.info("Create pantry button tapped")
//                    }, label: {
//                        Image(systemName: "plus")
//                    })
//                }
//            }
//        }
//        .task {
//            await vm.loadPantries()
//            logger.info("Loaded pantries: private = \(vm.privatePantries.count), shared = \(vm.sharedPantries.count)")
//        }
//        .sheet(item: $sharingPantry) { pantry in
//            SharePantryView(pantry: pantry)
//        }
//        .sheet(isPresented: $showCreatePantrySheet) {
//            CreatePantryView { newPantry in
//                Task {
//                    await vm.loadPantries()
//                    logger.info("Pantry created, reloaded pantries")
//                }
//            }
//        }
//        .alert("Error", isPresented: .constant(vm.error != nil), actions: {
//            Button("OK") { vm.error = nil }
//        }, message: {
//            Text(vm.error ?? "An unknown error occurred")
//        })
//    }
//    
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
