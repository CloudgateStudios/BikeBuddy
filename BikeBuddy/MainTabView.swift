//
//  MainTabView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces MainTabViewController (UITabBarController).
/// Three tabs: Stations List, Map, Settings.
struct MainTabView: View {

    var body: some View {
        TabView {
            NavigationStack {
                StationsListView()
            }
            .tabItem {
                Label(StringsService.getStringFor(key: "StationsListTabBarItemLabel"), systemImage: "list.bullet")
            }

            NavigationStack {
                MapView()
            }
            .tabItem {
                Label(StringsService.getStringFor(key: "MapTabBarItemLabel"), systemImage: "map")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(StringsService.getStringFor(key: "SettingsTabBarItemLabel"), systemImage: "gear")
            }
        }
        .tint(Color(red: 60/255, green: 163/255, blue: 220/255))
    }
}
