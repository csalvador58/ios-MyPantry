//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI

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

#Preview {
    Group {
        let mockViewModel = MockListItemsViewModel()
        @State var item = mockViewModel.items.first
        ViewItemView(item: item!)
    }
}
