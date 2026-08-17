//
//  SettingsView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces SettingsTableViewController.
struct SettingsView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            // MARK: Service section
            Section(header: Text("SettingsServiceGroup", bundle: .bikeBuddyKit)) {

                NavigationLink {
                    SettingsSelectNetworkView()
                } label: {
                    HStack {
                        Text("SettingsServiceNetwork", bundle: .bikeBuddyKit)
                        Spacer()
                        Text(networkDisplayName)
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    SettingsNumberOfClosestStationsView()
                } label: {
                    HStack {
                        Text("SettingsServiceNumberOfStations", bundle: .bikeBuddyKit)
                        Spacer()
                        Text(String(appViewModel.numberOfClosestStations))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: Appearance section
            Section(header: Text("SettingsAppearanceGroup", bundle: .bikeBuddyKit)) {
                Picker(selection: Binding(
                    get: { appViewModel.appearanceMode },
                    set: { appViewModel.selectAppearanceMode($0) }
                )) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                } label: {
                    Text("SettingsThemeLabel", bundle: .bikeBuddyKit)
                }
            }

            // MARK: General section
            Section(header: Text("SettingsGeneralGroup", bundle: .bikeBuddyKit)) {

                NavigationLink {
                    SettingsAboutView()
                } label: {
                    Text("SettingsGeneralAboutDeliberateTypo", bundle: .bikeBuddyKit)
                }

                ShareLink(
                    item: String(localized: "SettingsShareMessageContent", bundle: .bikeBuddyKit) + " " + Constants.ExtneralURL.AppStoreDeepLink
                ) {
                    Text("SettingsGeneralTellYourFriends", bundle: .bikeBuddyKit)
                        .foregroundStyle(.primary)
                }

                Button {
                    goToAppStorePage()
                } label: {
                    Text("SettingsGeneralRateApp", bundle: .bikeBuddyKit)
                        .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Text("SettingsNavBarTitle", bundle: .bikeBuddyKit))
    }

    // MARK: - Helpers

    private var networkDisplayName: String {
        guard !appViewModel.bikeServiceCityName.isEmpty else {
            return appViewModel.bikeServiceName
        }
        return "\(appViewModel.bikeServiceName) — \(appViewModel.bikeServiceCityName)"
    }

    // MARK: - Actions

    private func goToAppStorePage() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.GoToAppStoreLink)
        if let url = URL(string: Constants.ExtneralURL.AppStoreDeepLink) {
            openURL(url)
        }
    }
}
