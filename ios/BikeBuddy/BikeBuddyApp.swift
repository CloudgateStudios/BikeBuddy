//
//  BikeBuddyApp.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

@main
struct BikeBuddyApp: App {

    // AppViewModel drives all top-level state; shared via environment.
    @StateObject private var appViewModel = AppViewModel.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .tint(Color("BikeBuddyBlue"))
                .preferredColorScheme(appViewModel.appearanceMode.colorScheme)
                .onContinueUserActivity(Constants.UserActivity.StationActivityTypeIdentifier) { activity in
                    handleUserActivity(activity)
                }
        }
    }

    // MARK: - User Activity (Handoff / Spotlight)

    private func handleUserActivity(_ activity: NSUserActivity) {
        // Handled inside ContentView / MapView via environment; no-op at app level.
        _ = activity
    }
}
