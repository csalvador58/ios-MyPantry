//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//
import Models
import SwiftUI


struct ItemRow: View {
    let item: Item
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
            }
            Spacer()
            Text(item.status.descr)
                .font(.caption)
                .padding(5)
                .background(statusColor(for: item.status))
                .cornerRadius(5)
        }
    }
    
    private func statusColor(for status: ItemStatus) -> Color {
        switch status {
        case .inStock:
            return .green
        case .lowStock:
            return .yellow
        case .outOfStock:
            return .red
        case .inactive:
            return .gray
        }
    }
}

