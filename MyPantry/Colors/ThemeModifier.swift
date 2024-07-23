//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

struct ThemeModifier: ViewModifier {
    let theme: AppTheme
    
    func body(content: Content) -> some View {
        content
            .accentColor(theme.primaryColor)
            .background(theme.backgroundColor)
    }
}

extension View {
    func withTheme(_ theme: AppTheme = .default) -> some View {
        modifier(ThemeModifier(theme: theme))
    }
}
