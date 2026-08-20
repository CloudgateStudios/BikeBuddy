//
//  StationsListView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import CoreLocation
import BikeBuddyKit

/// Shows the closest N bike stations to the user's current location.
struct StationsListView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.openURL) private var openURL
    @State private var locationManager = LocationManager()

    private var closestStations: [Station] {
        var lat = locationManager.coordinate.latitude
        var lon = locationManager.coordinate.longitude
        // In the screenshot run the simulator has no real GPS fix (both values are 0).
        // Fall back to the centre of the mock-station cluster (Midtown Manhattan) so
        // getClosestStations returns the pre-seeded stations instead of an empty list.
        if lat == 0.0 && lon == 0.0 &&
            ProcessInfo.processInfo.environment["UI_TESTING_SCREENSHOTS"] == "1" {
            lat = 40.7563
            lon = -73.9914
        }
        return appViewModel.closestStations(latitude: lat, longitude: lon)
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

        return Group {
            if appViewModel.isLoadingStations && appViewModel.stations.isEmpty {
                loadingView
            } else if stations.isEmpty {
                emptyStateView
            } else {
                stationList(stations)
            }
        }
        .navigationTitle(Text("StationsListNavBarTitle", bundle: .bikeBuddyKit))
        .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
        .onAppear { locationManager.startUpdatingLocation() }
        .onDisappear { locationManager.stopUpdatingLocation() }
    }

    // MARK: - Station list

    private func stationList(_ stations: [Station]) -> some View {
        List {
            if !locationManager.canProvideLocation {
                Section {
                    locationUnavailableNotice
                }
            }

            ForEach(stations, id: \.id) { station in
                NavigationLink {
                    StationDetailView(station: station)
                } label: {
                    StationRowView(station: station, showDistance: locationIsKnown)
                        .equatable()
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await appViewModel.refreshStations()
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
    }

    // MARK: - Empty state

    /// Shows why the list is empty. `refreshStations` already builds a message for
    /// both the failed-request and no-stations-returned cases, so prefer that over
    /// the generic copy and give the user a way to retry without leaving the tab.
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
