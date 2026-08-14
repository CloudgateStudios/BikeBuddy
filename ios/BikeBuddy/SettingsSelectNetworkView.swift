//
//  SettingsSelectNetworkView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces SettingsSelectNetworkViewController.
/// Thin wrapper around NetworkPickerView for the Settings context.
struct SettingsSelectNetworkView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NetworkPickerView(
            searchPrompt: String(localized: "SettingsSelectNetworkSearchBarPlaceholder", bundle: .bikeBuddyKit),
            onSelect: { network in
                selectNetwork(network)
            }
        )
        .navigationTitle(Text("SettingsSelectNetworkNavBarTitle", bundle: .bikeBuddyKit))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions

    private func selectNetwork(_ network: Network) {
        let oldNetwork = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceName)
        let analyticAttr = [
            Constants.AnalyticEventDetail.OldCity: oldNetwork,
            Constants.AnalyticEventDetail.NewCity: network.name ?? ""
        ]
        AnalyticsService.sharedInstance.pegUserAction(
            eventName: Constants.AnalyticEvent.SelectNewCity,
            customAttributes: analyticAttr as [String: AnyObject]
        )
        appViewModel.selectNetwork(network)
        Task { await appViewModel.refreshStations() }
        dismiss()
    }
}
