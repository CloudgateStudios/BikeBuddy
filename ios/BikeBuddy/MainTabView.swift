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
                Label { Text("StationsListTabBarItemLabel", bundle: .bikeBuddyKit) } icon: { Image(systemName: "list.bullet") }
            }

            NavigationStack {
                MapView()
            }
            .tabItem {
                Label { Text("MapTabBarItemLabel", bundle: .bikeBuddyKit) } icon: { Image(systemName: "map") }
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label { Text("SettingsTabBarItemLabel", bundle: .bikeBuddyKit) } icon: { Image(systemName: "gear") }
            }
        }
        .tint(Color("BikeBuddyBlue"))
        // Force the traditional bottom tab bar on all devices (including iPad).
        // iOS 18 introduced .sidebarAdaptable which makes iPad show a sidebar by
        // default; .tabBarOnly opts back in to the bottom-bar layout everywhere.
        // (The old .tabBar style was removed in iOS 18.)
        .tabViewStyle(.tabBarOnly)
    }
}
