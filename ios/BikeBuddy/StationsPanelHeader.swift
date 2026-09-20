//
//  StationsPanelHeader.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import BikeBuddyKit

// MARK: - Panel header

/// Title, the current network, and the way in to settings.
///
/// The network reads as a control rather than a caption because it is the one setting
/// that changes with any regularity — a bike share app is only useful once it is
/// pointed at the right city, and travelling is exactly when that changes. The gear
/// keeps everything that does not.
struct StationsPanelHeader: View {

    /// The screenshot run drives both of these, and neither has stable visible text to
    /// find it by — the network button is named after whatever network is selected,
    /// and the gear is an icon.
    static let networkButtonIdentifier = "stationsPanel.networkButton"
    static let settingsButtonIdentifier = "stationsPanel.settingsButton"

    @Environment(AppViewModel.self) private var appViewModel

    let onOpenNetworkPicker: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text("StationsListNavBarTitle", bundle: .bikeBuddyKit)
                    .font(.title2.weight(.bold))

                Button(action: onOpenNetworkPicker) {
                    HStack(spacing: 4) {
                        Text(appViewModel.bikeServiceName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        if !appViewModel.bikeServiceCityName.isEmpty {
                            Text(appViewModel.bikeServiceCityName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)
                    // The row of text is 18pt tall on its own, which is a fifth of
                    // Apple's minimum target for the control that changes networks.
                    // The hit area is padded up to 44 and the shape follows it; the
                    // stack's spacing absorbs most of the growth.
                    .frame(minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .hoverEffect(.highlight)
                .accessibilityLabel(Text("StationsPanelChangeNetworkAccessibilityLabel", bundle: .bikeBuddyKit))
                .accessibilityIdentifier(StationsPanelHeader.networkButtonIdentifier)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onOpenSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(Color(.secondarySystemFill), in: Circle())
            }
            .buttonStyle(.plain)
            .hoverEffect(.lift)
            .accessibilityLabel(Text("SettingsNavBarTitle", bundle: .bikeBuddyKit))
            .accessibilityIdentifier(StationsPanelHeader.settingsButtonIdentifier)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

// MARK: - Settings sheet

/// Settings is a sheet now rather than a tab, so it needs its own stack and a way out.
struct SettingsSheet: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SettingsView()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Text("GeneralButtonDone", bundle: .bikeBuddyKit)
                        }
                    }
                }
        }
    }
}
