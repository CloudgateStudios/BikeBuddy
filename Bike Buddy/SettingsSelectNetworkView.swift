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
/// Searchable, alphabetically-sectioned list of bike networks; selecting one updates settings
/// and pops the navigation stack.
struct SettingsSelectNetworkView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isLoadingNetworks = false
    @State private var sortedNetworksList: [(key: String, value: [Network])] = []
    @State private var simpleNetworksList: [Network] = []
    @State private var searchText: String = ""

    private var isSearching: Bool { !searchText.isEmpty }

    var body: some View {
        Group {
            if isLoadingNetworks {
                VStack(spacing: 16) {
                    ProgressView()
                    Text(StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
                        .foregroundStyle(.secondary)
                }
            } else {
                networkList
            }
        }
        .navigationTitle(StringsService.getStringFor(key: "SettingsSelectNetworkNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            prompt: StringsService.getStringFor(key: "SettingsSelectNetworkSearchBarPlaceholder")
        )
        .onChange(of: searchText) { text in
            applySearch(text)
        }
        .task {
            await loadNetworksIfNeeded()
        }
    }

    @ViewBuilder
    private var networkList: some View {
        List {
            if isSearching {
                ForEach(simpleNetworksList, id: \.id) { network in
                    networkRow(network)
                }
            } else {
                ForEach(sortedNetworksList, id: \.key) { section in
                    Section(header: Text(section.key)) {
                        ForEach(section.value, id: \.id) { network in
                            networkRow(network)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func networkRow(_ network: Network) -> some View {
        Button {
            selectNetwork(network)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(network.name ?? "")
                    .foregroundStyle(.primary)
                Text(locationString(for: network))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Data loading

    private func loadNetworksIfNeeded() async {
        if !Networks.sharedInstance.list.isEmpty {
            sortedNetworksList = Networks.sharedInstance.networksBySection
            return
        }
        isLoadingNetworks = true
        await withCheckedContinuation { continuation in
            NetworksDataService.sharedInstance.getAllNetworkData(apiUrl: Constants.CityBikes.NetworksAPI) { responseObject, _ in
                Task { @MainActor in
                    Networks.sharedInstance.list = responseObject
                    self.sortedNetworksList = Networks.sharedInstance.networksBySection
                    self.isLoadingNetworks = false
                    continuation.resume()
                }
            }
        }
    }

    private func applySearch(_ text: String) {
        if text.isEmpty {
            sortedNetworksList = Networks.sharedInstance.networksBySection
        } else {
            simpleNetworksList = Networks.searchThroughList(searchText: text)
        }
    }

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
        // Trigger a station refresh for the new city
        Task { await appViewModel.refreshStations() }
        dismiss()
    }

    private func locationString(for network: Network) -> String {
        let city = network.location?.city ?? ""
        let country = CountryCleanupService.sharedInstance.mapCountryCodeToString(
            countryCode: network.location?.country ?? ""
        )
        return "\(city), \(country)"
    }
}
