//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI

struct EditableProperty: Identifiable {
    let id: String
    let name: String

    init(_ name: String) {
        self.id = name
        self.name = name
    }
}

@MainActor
struct ViewItemView: View {
    @State private var item: Item
    @State private var editingProperty: EditableProperty?
    @State private var isEditMode: Bool = false

    init(item: Item) {
        _item = State(initialValue: item)
    }

    var body: some View {
        NavigationStack {
            Form {
                mainDetailsSection
                customContentSection
                notesSection
            }
            .navigationTitle("Item Details")
            .toolbar {
                Button {
                    isEditMode.toggle()
                } label: {
                    Text(isEditMode ? "Done" : "Edit")
                }
            }
        }
        .sheet(item: $editingProperty) { property in
            EditPropertyView(item: $item, property: property.name)
        }
    }

    private var mainDetailsSection: some View {
        Section(header: Text("Main Details")) {
            detailRow(title: "Name", value: item.name, property: "name")
            detailRow(title: "Quantity", value: "\(item.quantity)", property: "quantity")
            detailRow(title: "Quantity Desired", value: item.quantityDesired.map { "\($0)" } ?? "N/A", property: "quantityDesired")
            detailRow(title: "Barcode", value: item.barcode ?? "N/A", property: "barcode")
            detailRow(title: "Favorite", value: item.favorite ? "Yes" : "No", property: "favorite")
            detailRow(title: "Status", value: item.status.descr, property: "status")
            detailRow(title: "Date Added", value: formatDate(item.dateAdded), property: "dateAdded")
            detailRow(title: "Last Updated", value: formatDate(item.dateLastUpdated), property: "dateLastUpdated")
            detailRow(title: "Expire Date", value: item.expireDate.map { formatDate($0) } ?? "N/A", property: "expireDate")
        }
    }

    private var customContentSection: some View {
        Section(header: Text("Custom Content")) {
            detailRow(title: "Custom 1", value: item.customContent1 ?? "N/A", property: "customContent1")
            detailRow(title: "Custom 2", value: item.customContent2 ?? "N/A", property: "customContent2")
            detailRow(title: "Custom 3", value: item.customContent3 ?? "N/A", property: "customContent3")
        }
    }

    private var notesSection: some View {
        Section(header: Text("Notes")) {
            detailRow(title: "Note", value: item.note ?? "N/A", property: "note")
        }
    }

    private func detailRow(title: String, value: String, property: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
            if isEditMode {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        editingProperty = EditableProperty(property)
                    }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct EditPropertyView: View {
    @Binding var item: Item
    let property: String
    @Environment(\.dismiss) private var dismiss

    @State private var editedValue: String = ""
    @State private var editedDate: Date = .init()
    @State private var editedBool: Bool = false

    private var propertySetters: [String: () -> Void] {
        [
            "name": { item.name = editedValue },
            "quantity": { item.quantity = Int(editedValue) ?? item.quantity },
            "quantityDesired": { item.quantityDesired = Int(editedValue) },
            "barcode": { item.barcode = editedValue.isEmpty ? nil : editedValue },
            "favorite": { item.favorite = editedBool },
            "customContent1": { item.customContent1 = editedValue.isEmpty ? nil : editedValue },
            "customContent2": { item.customContent2 = editedValue.isEmpty ? nil : editedValue },
            "customContent3": { item.customContent3 = editedValue.isEmpty ? nil : editedValue },
            "dateAdded": { item.dateAdded = editedDate },
            "dateLastUpdated": { item.dateLastUpdated = editedDate },
            "expireDate": { item.expireDate = editedDate },
            "note": { item.note = editedValue.isEmpty ? nil : editedValue },
            "status": {
                if let newStatus = ItemStatus(rawValue: Int(editedValue) ?? item.status.rawValue) {
                    item.status = newStatus
                }
            }
        ]
    }

    private var propertyGetters: [String: () -> Void] {
        [
            "name": { editedValue = item.name },
            "quantity": { editedValue = "\(item.quantity)" },
            "quantityDesired": { editedValue = item.quantityDesired.map { "\($0)" } ?? "" },
            "barcode": { editedValue = item.barcode ?? "" },
            "favorite": { editedBool = item.favorite },
            "customContent1": { editedValue = item.customContent1 ?? "" },
            "customContent2": { editedValue = item.customContent2 ?? "" },
            "customContent3": { editedValue = item.customContent3 ?? "" },
            "dateAdded": { editedDate = item.dateAdded },
            "dateLastUpdated": { editedDate = item.dateLastUpdated },
            "expireDate": { editedDate = item.expireDate ?? Date() },
            "note": { editedValue = item.note ?? "" },
            "status": { editedValue = String(item.status.rawValue) }
        ]
    }

    var body: some View {
        NavigationStack {
            Form {
                propertyEditView
            }
            .navigationTitle("Edit \(property.capitalized)")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveChanges() }
            )
            .onAppear { setupInitialValue() }
        }
    }

    private var propertyEditView: some View {
        Group {
            switch property {
            case "name", "barcode", "customContent1", "customContent2", "customContent3", "note":
                TextField("Enter new value", text: $editedValue)
            case "quantity", "quantityDesired":
                TextField("Enter new value", text: $editedValue)
                    .keyboardType(.numberPad)
            case "favorite":
                Toggle("Favorite", isOn: $editedBool)
            case "status":
                Picker("Status", selection: $editedValue) {
                    ForEach(ItemStatus.allCases) { status in
                        Text(status.descr).tag(String(status.rawValue))
                    }
                }
            case "dateAdded", "dateLastUpdated", "expireDate":
                DatePicker("Select date", selection: $editedDate, displayedComponents: [.date])
            default:
                Text("Unsupported property")
            }
        }
    }

    private func setupInitialValue() {
        propertyGetters[property]?()
    }

    private func saveChanges() {
        propertySetters[property]?()
        dismiss()
    }
}

#Preview {
    Group {
        let mockViewModel = MockListItemsViewModel()
        @State var item = mockViewModel.items.first
        ViewItemView(item: item!)
    }
}
