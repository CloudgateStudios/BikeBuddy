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

    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            // MARK: Service section
            Section(header: Text(StringsService.getStringFor(key: "SettingsServiceGroup"))) {

                NavigationLink {
                    SettingsSelectNetworkView()
                } label: {
                    HStack {
                        Text(StringsService.getStringFor(key: "SettingsServiceNetwork"))
                        Spacer()
                        Text(networkDisplayName)
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    SettingsNumberOfClosestStationsView()
                } label: {
                    HStack {
                        Text(StringsService.getStringFor(key: "SettingsServiceNumberOfStations"))
                        Spacer()
                        Text(String(appViewModel.numberOfClosestStations))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: General section
            Section(header: Text(StringsService.getStringFor(key: "SettingsGeneralGroup"))) {

                NavigationLink {
                    SettingsAboutView()
                } label: {
                    Text(StringsService.getStringFor(key: "SettingsGeneralAbout"))
                }

                ShareLink(
                    item: StringsService.getStringFor(key: "SettingsShareMessageContent") + " " + Constants.ExtneralURL.AppStoreDeepLink
                ) {
                    Text(StringsService.getStringFor(key: "SettingsGeneralTellYourFriends"))
                        .foregroundStyle(.primary)
                }

                Button {
                    goToAppStorePage()
                } label: {
                    Text(StringsService.getStringFor(key: "SettingsGeneralRateApp"))
                        .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(StringsService.getStringFor(key: "SettingsNavBarTitle"))
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
