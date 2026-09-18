//
//  StationsPanel.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import CoreLocation
import BikeBuddyKit

/// The closest stations, with the network and settings controls above them.
///
/// One component serves both layouts: it is the sidebar of the iPad split view and the
/// content of the iPhone sheet. Only how a row is chosen differs, and that is a real
/// platform difference rather than a style choice — see `stationList`.
struct StationsPanel: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) private var openURL

    @State private var locationManager = LocationManager()
    @State private var isShowingSettings = false
    @State private var isShowingNetworkPicker = false

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    private var closestStations: [Station] {
        appViewModel.closestStations(
            latitude: locationManager.coordinate.latitude,
            longitude: locationManager.coordinate.longitude
        )
    }

    private var locationIsKnown: Bool {
        locationManager.coordinate.latitude != 0.0 || locationManager.coordinate.longitude != 0.0
    }

    // MARK: - Body

    var body: some View {
        // Read the computed property once per evaluation and pass the result down.
        // Touching it in both the isEmpty check and the ForEach ran the whole
        // map-and-sort twice for every render.
        let stations = closestStations

        return VStack(spacing: 0) {
            StationsPanelHeader(
                onOpenNetworkPicker: { isShowingNetworkPicker = true },
                onOpenSettings: { isShowingSettings = true }
            )

            if appViewModel.isLoadingStations && appViewModel.stations.isEmpty {
                loadingView
            } else if stations.isEmpty {
                emptyStateView
            } else {
                stationList(stations)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { locationManager.startUpdatingLocation() }
        .onDisappear { locationManager.stopUpdatingLocation() }
        .onChange(of: locationManager.coordinate.latitude, initial: true) { _, _ in
            appViewModel.userCoordinate = locationManager.coordinate
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsSheet()
        }
        .sheet(isPresented: $isShowingNetworkPicker) {
            NavigationStack {
                SettingsSelectNetworkView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                isShowingNetworkPicker = false
                            } label: {
                                Text("GeneralButtonCancel", bundle: .bikeBuddyKit)
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Station list

    /// Regular width uses `List(selection:)`, which a split view sidebar turns into
    /// tap-to-select and — the part worth having — arrow-key navigation with a
    /// keyboard attached. In a plain stack that same selection only responds in edit
    /// mode, so compact drives the identical state from a button instead.
    @ViewBuilder
    private func stationList(_ stations: [Station]) -> some View {
        @Bindable var appViewModel = appViewModel

        if isRegularWidth {
            List(selection: $appViewModel.selectedStationID) {
                locationSection
                ForEach(stations, id: \.id) { station in
                    StationRowView(station: station, showDistance: locationIsKnown)
                        .equatable()
                        .tag(station.id)
                }
            }
            .listStyle(.sidebar)
            .refreshable { await appViewModel.refreshStations() }
        } else {
            List {
                locationSection
                ForEach(stations, id: \.id) { station in
                    Button {
                        appViewModel.selectedStationID = station.id
                    } label: {
                        StationRowView(station: station, showDistance: locationIsKnown)
                            .equatable()
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .refreshable { await appViewModel.refreshStations() }
        }
    }

    @ViewBuilder
    private var locationSection: some View {
        if !locationManager.canProvideLocation {
            Section {
                locationUnavailableNotice
            }
        }
    }

    // MARK: - Location unavailable notice

    /// Without a location fix getClosestStations cannot sort, and falls back to the
    /// first N stations in feed order. That looks identical to a real result, so say
    /// so plainly rather than presenting arbitrary stations as the closest ones.
    private var locationUnavailableNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("StationsListLocationOffTitle", bundle: .bikeBuddyKit)
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: "location.slash")
                    .foregroundStyle(.orange)
            }

            Text("StationsListLocationOffMessage", bundle: .bikeBuddyKit)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: resolveLocationAccess) {
                // Before the user has answered we can still prompt in app. Afterwards
                // iOS ignores the request, so the only way back is the Settings app.
                if locationManager.authorizationStatus == .notDetermined {
                    Text("LocationAccessButton", bundle: .bikeBuddyKit)
                } else {
                    Text("GeneralButtonOpenSettings", bundle: .bikeBuddyKit)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }

    private func resolveLocationAccess() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAuthorization()
            return
        }

        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            openURL(settingsURL)
        }
    }

    // MARK: - Loading state

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("StationsListLoadingMessage", bundle: .bikeBuddyKit)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty state

    /// Shows why the list is empty. `refreshStations` already builds a message for
    /// both the failed-request and no-stations-returned cases, so prefer that over
    /// the generic copy and give the user a way to retry without leaving the panel.
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label {
                Text("StationsListNoDataTitle", bundle: .bikeBuddyKit)
            } icon: {
                Image(systemName: "bicycle")
            }
        } description: {
            if let loadError = appViewModel.stationsLoadError {
                Text(loadError)
            } else {
                Text("StationsListNoDataMessage", bundle: .bikeBuddyKit)
            }
        } actions: {
            Button {
                Task { await appViewModel.refreshStations() }
            } label: {
                Text("GeneralButtonTryAgain", bundle: .bikeBuddyKit)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Panel header

/// Title, the current network, and the way in to settings.
///
/// The network reads as a control rather than a caption because it is the one setting
/// that changes with any regularity — a bike share app is only useful once it is
/// pointed at the right city, and travelling is exactly when that changes. The gear
/// keeps everything that does not.
private struct StationsPanelHeader: View {

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
            VStack(alignment: .leading, spacing: 6) {
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
                    .frame(width: 38, height: 38)
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

// MARK: - Station row

struct StationRowView: View, Equatable {

    let station: Station
    let showDistance: Bool

    nonisolated static func == (lhs: StationRowView, rhs: StationRowView) -> Bool {
        lhs.station.id == rhs.station.id &&
        lhs.station.availableBikes == rhs.station.availableBikes &&
        lhs.station.availableDocks == rhs.station.availableDocks &&
        lhs.station.distanceFromUser == rhs.station.distanceFromUser &&
        lhs.showDistance == rhs.showDistance
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Name + distance
            VStack(alignment: .leading, spacing: 4) {
                Text(station.stationName)
                    .font(.body)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if showDistance {
                    Text(station.approximateDistanceAwayFromUser)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !station.streetAddress.isEmpty {
                    Text(station.streetAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Availability badges
            HStack(spacing: 20) {
                availabilityBadge(
                    count: station.availableBikes,
                    icon: "bicycle",
                    color: availabilityColor(station.availableBikes)
                )
                availabilityBadge(
                    count: station.availableDocks,
                    icon: "arrow.down.to.line",
                    color: availabilityColor(station.availableDocks)
                )
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func availabilityBadge(count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Group {
                if count < 0 {
                    Text(verbatim: "—")
                } else {
                    Text(count, format: .number)
                }
            }
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
                .monospacedDigit()
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 36)
    }

    private func availabilityColor(_ count: Int) -> Color {
        switch count {
        case 0:     .red
        case 1...2: .orange
        default:    .primary
        }
    }
}
