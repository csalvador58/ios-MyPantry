import SwiftUI
import Models
import CloudKit
import os

struct SharePantryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.pantryService) var pantryService
    @State private var sharingInfo: SharingInfo?
    @State private var isLoading = false
    @State private var error: String?
    let pantry: Pantry
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SharePantryView")
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Preparing to share...")
            } else if let sharingInfo = sharingInfo {
                CloudSharingView(
                    share: sharingInfo.share,
                    container: CKContainer(identifier: Config.containerIdentifier),
                    pantry: pantry
                )
            } else {
                VStack {
                    Text("Ready to share \(pantry.name)")
                    Button("Share Pantry") {
                        Task {
                            await sharePantry()
                        }
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(error != nil), actions: {
            Button("OK") {
                error = nil
                dismiss()
            }
        }, message: {
            Text(error ?? "An unknown error occurred")
        })
    }
    
    private func sharePantry() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            sharingInfo = try await pantryService.createSharedPantry(pantry)
            logger.info("Successfully created shared pantry: \(pantry.id)")
        } catch {
            self.error = error.localizedDescription
            logger.error("Failed to create shared pantry: \(error.localizedDescription)")
            print("Error creating shared pantry: \(error)")
        }
    }
}

// ... Keep the existing CloudSharingView implementation ...

////
////  My Pantry
////  Created by Chris Salvador on 2024
////  SWD Creative Labs
////
//import CloudKit
//import Models
//import SwiftUI
//
//struct SharePantryView: View {
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.pantryService) var pantryService
//    @State private var sharingInfo: SharingInfo?
//    let pantry: Pantry
//    
//    var body: some View {
//        Group {
//            if let sharingInfo = sharingInfo {
//                CloudSharingView(
//                    share: sharingInfo.share,
//                    container: CKContainer(identifier: Config.containerIdentifier),
//                    pantry: pantry
//                )
//            } else {
//                ProgressView()
//            }
//        }
//        .onAppear {
//            Task {
//                do {
//                    sharingInfo = try await pantryService.createSharedPantry(pantry)
//                } catch {
//                    print("Failed to create shared pantry: \(error)")
//                    dismiss()
//                }
//            }
//        }
//    }
//}
//
struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let pantry: Pantry
    
    func makeUIViewController(context: Context) -> some UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowReadWrite, .allowPrivate]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        var parent: CloudSharingView
        
        init(_ parent: CloudSharingView) {
            self.parent = parent
        }
        
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Failed to save share: \(error)")
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            return parent.pantry.name
        }
    }
}
