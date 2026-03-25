//
//  PrimaryButtonStyle.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI

/// Reusable styled button matching the app's theme colour (RGB 60, 163, 220).
/// Replaces ThemeService.themeButton(button:) applied in every UIKit viewDidLoad.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("BikeBuddyBlue"))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}
