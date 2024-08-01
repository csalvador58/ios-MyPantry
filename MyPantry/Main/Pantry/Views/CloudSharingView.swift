//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Models
import SwiftUI

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

struct SharePantryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.pantryService) var pantryService
    @State private var sharingInfo: SharingInfo?
    let pantry: Pantry
    
    var body: some View {
        Group {
            if let sharingInfo = sharingInfo {
                CloudSharingView(
                    share: sharingInfo.share,
                    container: CKContainer(identifier: Config.containerIdentifier),
                    pantry: pantry
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                do {
                    sharingInfo = try await pantryService.createSharedPantry(pantry)
                } catch {
                    print("Failed to create shared pantry: \(error)")
                    dismiss()
                }
            }
        }
    }
}
