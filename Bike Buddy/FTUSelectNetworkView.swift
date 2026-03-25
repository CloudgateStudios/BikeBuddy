//
//  FTUSelectNetworkView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

/// Replaces FTUSelectNetworkViewController.
/// Displays a searchable, alphabetically-sectioned list of bike networks.
struct FTUSelectNetworkView: View {

    @EnvironmentObject var ftuViewModel: FTUViewModel
    @State private var navigateToFinished = false

    var body: some View {
        Group {
            if ftuViewModel.isLoadingNetworks {
                VStack(spacing: 16) {
                    ProgressView()
                    Text(StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
                        .foregroundStyle(.secondary)
                }
            } else {
                networkList
            }
        }
        .navigationTitle(StringsService.getStringFor(key: "SelectNetworkNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToFinished) {
            FTUFinishedView()
        }
        .onChange(of: ftuViewModel.currentStep) { step in
            if step == .finished { navigateToFinished = true }
        }
        .searchable(
            text: $ftuViewModel.searchText,
            prompt: StringsService.getStringFor(key: "SelectNetworkSearchBarPlaceholder")
        )
    }

    @ViewBuilder
    private var networkList: some View {
        List {
            if ftuViewModel.isSearching {
                ForEach(ftuViewModel.simpleNetworksList, id: \.id) { network in
                    networkRow(network)
                }
            } else {
                ForEach(ftuViewModel.sortedNetworksList, id: \.key) { section in
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
            ftuViewModel.selectNetwork(network)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(network.name ?? "")
                    .foregroundStyle(.primary)
                Text(ftuViewModel.locationString(for: network))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
