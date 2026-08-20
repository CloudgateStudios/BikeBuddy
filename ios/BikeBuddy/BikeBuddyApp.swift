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
    @State private var appViewModel = AppViewModel.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appViewModel)
                .tint(Color("BikeBuddyBlue"))
                .preferredColorScheme(appViewModel.appearanceMode.colorScheme)
                .onContinueUserActivity(Constants.UserActivity.StationActivityTypeIdentifier) { activity in
                    handleUserActivity(activity)
                }
        }
    }

    // MARK: - User Activity (Handoff / Spotlight)

    /// StationDetailView donates each station it shows to Spotlight, so tapping one of
    /// those results launches us with the activity below. The station id travels in
    /// userInfo under the same key the donation writes, and is required there via
    /// requiredUserInfoKeys, so anything reaching us has one.
    private func handleUserActivity(_ activity: NSUserActivity) {
        guard let stationID = activity.userInfo?["stationId"] as? String else { return }

        appViewModel.openStationFromSpotlight(id: stationID)
    }
}
