//
//  ItemListView.swift
//  MyPantry
//
//  Created by Salvador on 7/16/24.
//

import SwiftUI

struct ItemListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .padding()
            .navigationTitle("My Pantry")
            .toolbar {
                Button {
                    
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
        }
    }
}

#Preview {
    ItemListView()
}
