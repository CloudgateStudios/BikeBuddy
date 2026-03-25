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
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

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
                        Text(appViewModel.bikeServiceName)
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

                Button {
                    shareTellYourFriends()
                } label: {
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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }

    // MARK: - Actions

    private func goToAppStorePage() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.GoToAppStoreLink)
        if let url = URL(string: Constants.ExtneralURL.AppStoreDeepLink) {
            UIApplication.shared.open(url)
        }
    }

    private func shareTellYourFriends() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.ShareAppWithFriends)
        let message = StringsService.getStringFor(key: "SettingsShareMessageContent") + " " + Constants.ExtneralURL.AppStoreDeepLink
        shareItems = [message]
        showShareSheet = true
    }
}
