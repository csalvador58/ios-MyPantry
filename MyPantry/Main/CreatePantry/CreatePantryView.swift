//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import CloudKit
import Models
import SwiftUI
import UIKit

@MainActor
struct CreatePantryView<ViewModel: CreatePantryViewModel>: View {
    @State var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var sharePresented = false
    @State private var shareItem: CKShare?

    var onComplete: ((Pantry) -> Void)?

    init(viewModel: ViewModel, onComplete: ((Pantry) -> Void)? = nil) {
        _viewModel = State(initialValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pantry Details")) {
                    TextField("Pantry Name", text: $viewModel.name)
                }

                Section(header: Text("Sharing")) {
                    Toggle("Share this pantry", isOn: $viewModel.isShared)
                }

                Section {
                    Button(action: createPantry) {
                        if isCreating {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 20, alignment: .center)
                        } else {
                            Text("Create Pantry")
                                .frame(maxWidth: .infinity, minHeight: 20, alignment: .center)
                        }
                    }
                    .disabled(viewModel.name.isEmpty)
                    .padding()
                    .background(viewModel.name.isEmpty ? .backgroundColor : .primaryColor)
                    .foregroundStyle(viewModel.name.isEmpty ? .accent1Color : .white)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Create New Pantry")
            .alert("Error", isPresented: Binding<Bool>.constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .sheet(isPresented: $sharePresented) {
                if let shareItem = shareItem {
                    CloudSharingView(share: shareItem, container: CKContainer.default(), pantry: viewModel.name)
                }
            }
            .withTheme()
        }
    }

    private func createPantry() {
        isCreating = true
        Task {
            do {
                let newPantry = try await viewModel.createPantry()
                if viewModel.isShared, let shareReference = newPantry.shareReference {
                    do {
                        let record = try await CKContainer.default().privateCloudDatabase.record(for: shareReference.recordID)
                        if let share = record as? CKShare {
                            shareItem = share
                            sharePresented = true
                        } else {
                            throw NSError(domain: "PantryError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Retrieved record is not a CKShare"])
                        }
                    } catch {
                        throw NSError(domain: "PantryError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve share: \(error.localizedDescription)"])
                    }
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isCreating = false
        }
    }
}

struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let pantry: String

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowReadWrite, .allowPrivate]
        return controller
    }

    func updateUIViewController(_: UICloudSharingController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        var parent: CloudSharingView

        init(_ parent: CloudSharingView) {
            self.parent = parent
        }

        func cloudSharingController(_: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("Failed to save share: \(error.localizedDescription)")
        }

        func itemTitle(for _: UICloudSharingController) -> String? {
            return parent.pantry
        }
    }
}

#Preview {
    CreatePantryView(viewModel: MockCreatePantryViewModel())
}
