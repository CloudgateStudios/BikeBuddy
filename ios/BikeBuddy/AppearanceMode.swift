//
//  AppearanceMode.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

enum AppearanceMode: Int, CaseIterable {
    case automatic = 0
    case light = 1
    case dark = 2

    var colorScheme: ColorScheme? {
        switch self {
        case .automatic: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var displayName: String {
        switch self {
        case .automatic: return String(localized: "SettingsThemeAutomatic", bundle: .bikeBuddyKit)
        case .light: return String(localized: "SettingsThemeLight", bundle: .bikeBuddyKit)
        case .dark: return String(localized: "SettingsThemeDark", bundle: .bikeBuddyKit)
        }
    }
}
