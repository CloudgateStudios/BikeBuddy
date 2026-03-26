//
//  NetworkPickerView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Shared searchable, alphabetically-sectioned network picker.
/// Owns its own loading and search state; calls `onSelect` when the user
/// taps a row. Used by both `FTUSelectNetworkView` and `SettingsSelectNetworkView`.
struct NetworkPickerView: View {

    let searchPrompt: String
    let onSelect: (Network) -> Void

    @State private var isLoading = false
    @State private var sortedList: [(key: String, value: [Network])] = []
    @State private var filteredList: [Network] = []
    @State private var searchText = ""

    private var isSearching: Bool { !searchText.isEmpty }

    // MARK: - Body

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text(StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
                        .foregroundStyle(.secondary)
                }
            } else {
                networkList
            }
        }
        .searchable(text: $searchText, prompt: searchPrompt)
        .onChange(of: searchText) { _, text in applySearch(text) }
        .task { await loadNetworks() }
    }

    // MARK: - Network list

    @ViewBuilder
    private var networkList: some View {
        List {
            if isSearching {
                ForEach(filteredList, id: \.id) { network in
                    networkRow(network)
                }
            } else {
                ForEach(sortedList, id: \.key) { section in
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
            onSelect(network)
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

    private func loadNetworks() async {
        if !Networks.sharedInstance.list.isEmpty {
            sortedList = Networks.sharedInstance.networksBySection
            return
        }
        isLoading = true
        await withCheckedContinuation { continuation in
            NetworksDataService.sharedInstance.getAllNetworkData(apiUrl: Constants.CityBikes.NetworksAPI) { responseObject, _ in
                Task { @MainActor in
                    Networks.sharedInstance.list = responseObject
                    self.sortedList = Networks.sharedInstance.networksBySection
                    self.isLoading = false
                    continuation.resume()
                }
            }
        }
    }

    private func applySearch(_ text: String) {
        if text.isEmpty {
            sortedList = Networks.sharedInstance.networksBySection
        } else {
            filteredList = Networks.searchThroughList(searchText: text)
        }
    }

    private func locationString(for network: Network) -> String {
        let city = network.location?.city ?? ""
        let country = CountryCleanupService.sharedInstance.mapCountryCodeToString(
            countryCode: network.location?.country ?? ""
        )
        return "\(city), \(country)"
    }
}
