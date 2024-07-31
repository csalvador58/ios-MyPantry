//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import SwiftUI

extension ShapeStyle where Self == Color {
    static var primaryColor: Color { Color("primaryColor") }
    static var secondaryColor: Color { Color("secondaryColor") }
    static var backgroundColor: Color { Color("backgroundColor") }
    static var accent1Color: Color { Color("accent1Color") }
    static var accent2Color: Color { Color("accent2Color") }
    static var adaptiveTextColor: Color { Color("adaptiveTextColor") }
    static var adaptiveButtonTextColor: Color { Color("adaptiveButtonTextColor") }
}

struct AppTheme {
    let primaryColor: Color
    let secondaryColor: Color
    let backgroundColor: Color
    let accent1Color: Color
    let accent2Color: Color
    let adaptiveTextColor: Color
    let adaptiveButtonTextColor: Color

    static let `default` = AppTheme(
        primaryColor: .primaryColor,
        secondaryColor: .secondaryColor,
        backgroundColor: .backgroundColor,
        accent1Color: .accent1Color,
        accent2Color: .accent2Color,
        adaptiveTextColor: .adaptiveTextColor,
        adaptiveButtonTextColor: .adaptiveButtonTextColor
        
    )
}
