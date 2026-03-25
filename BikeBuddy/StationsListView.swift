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

/// Replaces StationsListTableViewController.
/// Shows the closest N bike stations to the user's current location.
struct StationsListView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var locationManager = LocationManager()

    // Derived from stations + current location
    private var closestStations: [Station] {
        let lat = locationManager.coordinate.latitude
        let lon = locationManager.coordinate.longitude
        return appViewModel.closestStations(latitude: lat, longitude: lon)
    }

    private var locationIsKnown: Bool {
        locationManager.coordinate.latitude != 0.0 || locationManager.coordinate.longitude != 0.0
    }

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
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }

    // MARK: - Station list

    private var stationList: some View {
        List {
            Section(header: Text(StringsService.getStringFor(key: "StationsListClosestStationsSectionHeader"))) {
                ForEach(closestStations, id: \.id) { station in
                    NavigationLink {
                        StationDetailView(station: station)
                    } label: {
                        StationRowView(station: station, showDistance: locationIsKnown)
                            .equatable()
                    }
                }
            }
        }
        .listStyle(.plain)
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
        VStack(spacing: 16) {
            Image(systemName: "bicycle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text(StringsService.getStringFor(key: "StationsListNoDataTitle"))
                .font(.headline)
            Text(StringsService.getStringFor(key: "StationsListNoDataMessage"))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Station row cell

/// Replaces StationTableViewCell (UITableViewCell).
struct StationRowView: View, Equatable {

    let station: Station
    let showDistance: Bool

    static func == (lhs: StationRowView, rhs: StationRowView) -> Bool {
        lhs.station.id == rhs.station.id &&
        lhs.station.availableBikes == rhs.station.availableBikes &&
        lhs.station.availableDocks == rhs.station.availableDocks &&
        lhs.showDistance == rhs.showDistance
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.stationName)
                    .font(.body)
                    .lineLimit(2)
                if showDistance {
                    Text(station.approximateDistanceAwayFromUser + " " + StringsService.getStringFor(key: "GeneralAwayLabel"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Docks tile
            StationCountTile(
                count: station.availableDocks,
                label: StringsService.getStringFor(key: "StationsListDocksAvailableLabel"),
                color: Color(.tertiaryLabel)
            )

            // Bikes tile
            StationCountTile(
                count: station.availableBikes,
                label: StringsService.getStringFor(key: "StationsListBikesAvailableLabel"),
                color: Color(.tertiarySystemFill)
            )
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Count tile

private struct StationCountTile: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(NumberFormatter.localizedString(from: count as NSNumber, number: .none))
                .font(.system(size: 28, weight: .regular))
            Text(label)
                .font(.system(size: 10))
                .multilineTextAlignment(.center)
        }
        .frame(width: 72, height: 96)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
