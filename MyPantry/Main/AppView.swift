//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

struct AppView: View {
    @Environment(\.privateItemManager) var privateItemManager
    @Environment(\.sharedItemManager) var sharedItemManger
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AppView()
}
