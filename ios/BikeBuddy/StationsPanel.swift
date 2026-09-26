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

    @Environment(LocationManager.self) private var locationManager
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
                availabilityBadge(count: station.availableBikes, icon: "bicycle")
                availabilityBadge(count: station.availableDocks, icon: "arrow.down.to.line")
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func availabilityBadge(count: Int, icon: String) -> some View {
        VStack(spacing: 3) {
            AvailabilityCount(count: count)
                .font(.title3.weight(.semibold))
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 36)
    }
}
