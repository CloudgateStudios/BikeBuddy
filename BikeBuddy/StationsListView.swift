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

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var locationManager = LocationManager()

    private var closestStations: [Station] {
        let lat = locationManager.coordinate.latitude
        let lon = locationManager.coordinate.longitude
        return appViewModel.closestStations(latitude: lat, longitude: lon)
    }

    private var locationIsKnown: Bool {
        locationManager.coordinate.latitude != 0.0 || locationManager.coordinate.longitude != 0.0
    }

    // MARK: - Body

    var body: some View {
        Group {
            if appViewModel.isLoadingStations && appViewModel.stations.isEmpty {
                loadingView
            } else if closestStations.isEmpty {
                emptyStateView
            } else {
                stationList
            }
        }
        .navigationTitle(StringsService.getStringFor(key: "StationsListNavBarTitle"))
        .onAppear  { locationManager.startUpdatingLocation() }
        .onDisappear { locationManager.stopUpdatingLocation() }
    }

    // MARK: - Station list

    private var stationList: some View {
        List {
            ForEach(closestStations, id: \.id) { station in
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

    // MARK: - Loading state

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text(StringsService.getStringFor(key: "StationsListLoadingMessage"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        ContentUnavailableView(
            StringsService.getStringFor(key: "StationsListNoDataTitle"),
            systemImage: "bicycle",
            description: Text(StringsService.getStringFor(key: "StationsListNoDataMessage"))
        )
    }
}

// MARK: - Station row

struct StationRowView: View, Equatable {

    let station: Station
    let showDistance: Bool

    static func == (lhs: StationRowView, rhs: StationRowView) -> Bool {
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
                    icon: "parkingsign",
                    color: availabilityColor(station.availableDocks)
                )
            }
        }
        .padding(.vertical, 6)
    }

    private func availabilityBadge(count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(count)")
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
