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
    @State private var loadError: String?
    @State private var sortedList: [(key: String, value: [Network])] = []
    @State private var filteredList: [Network] = []
    @State private var searchText = ""
    @FocusState private var searchIsFocused: Bool

    private var isSearching: Bool { !searchText.isEmpty }

    // MARK: - Body

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let loadError, sortedList.isEmpty {
                errorView(loadError)
            } else {
                networkList
            }
        }
        .searchable(text: $searchText, prompt: searchPrompt)
        .searchFocused($searchIsFocused)
        .background(findShortcut)
        .onChange(of: searchText) { _, text in applySearch(text) }
        .task { await loadNetworks() }
    }

    // MARK: - Hardware keyboard

    /// ⌘F puts the cursor in the search field, which is the Find shortcut anyone with
    /// a keyboard attached will reach for first on a list this long — there are
    /// roughly 700 networks, so scrolling to one is not a real option.
    ///
    /// Carried by an invisible button because a keyboard shortcut needs a control to
    /// hang off. `.opacity(0)` rather than `.hidden()`: hidden views are removed from
    /// layout, and a removed button registers no shortcut.
    private var findShortcut: some View {
        Button {
            searchIsFocused = true
        } label: {
            EmptyView()
        }
        .keyboardShortcut("f", modifiers: .command)
        .opacity(0)
        .accessibilityHidden(true)
    }

    // MARK: - Loading state

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("SelectNetworkLoadingPopupMessage", bundle: .bikeBuddyKit)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Error state

    /// The picker is the only way past this step during first-time use, so a failed
    /// download needs to say what went wrong and offer a retry rather than leaving
    /// an empty list behind.
    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label {
                Text("SelectNetworkLoadFailedTitle", bundle: .bikeBuddyKit)
            } icon: {
                Image(systemName: "exclamationmark.triangle")
            }
        } description: {
            Text(message)
        } actions: {
            Button {
                Task { await loadNetworks() }
            } label: {
                Text("GeneralButtonTryAgain", bundle: .bikeBuddyKit)
            }
            .buttonStyle(.borderedProminent)
        }
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
        // A plain list draws rows straight onto the system background, so that is the
        // colour the capped column has to blend into.
        .adaptiveListWidth(background: Color(.systemBackground))
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
            // The label is two short lines against a wide row, so without this the
            // pointer only finds the text rather than the row it selects.
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .hoverEffect(.highlight)
    }

    // MARK: - Data loading

    private func loadNetworks() async {
        if !Networks.sharedInstance.list.isEmpty {
            sortedList = Networks.sharedInstance.networksBySection
            return
        }
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        do {
            let networks = try await NetworksDataService.sharedInstance
                .getAllNetworkData(apiUrl: Constants.CityBikes.NetworksAPI)
            Networks.sharedInstance.list = networks
            sortedList = Networks.sharedInstance.networksBySection
        } catch {
            loadError = error.localizedDescription
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
