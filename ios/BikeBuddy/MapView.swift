//
//  MapView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import MapKit
import BikeBuddyKit

// MARK: - Map style options

private enum MapStyleOption: CaseIterable {
    case standard, satellite

    var mapStyle: MapStyle {
        switch self {
        case .standard:  .standard
        case .satellite: .hybrid
        }
    }

    /// SF Symbol representing the *other* style — shown on the toggle button
    /// so it communicates what tapping will switch *to*.
    var toggleIcon: String {
        switch self {
        case .standard:  "globe.americas.fill"
        case .satellite: "map"
        }
    }
}

// MARK: - Sheet item wrapper

/// Thin Identifiable wrapper around Station used for .sheet(item:).
/// Station is a class that does not conform to Identifiable, so we wrap it
/// here to avoid the isPresented + optional-state race condition that causes
/// an empty white sheet on first presentation.
private struct IdentifiableStation: Identifiable {
    let id: String
    let station: Station
}

// MARK: - Map view

/// Full-screen map showing all bike stations as Markers.
/// Tapping a Marker slides up a glass selection card with availability counts.
/// Tapping "Details" on the card presents StationDetailView as a sheet.
struct MapView: View {

    @EnvironmentObject var appViewModel: AppViewModel

    /// Tag value from the Map selection binding — matches Station.id (String).
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedStationID: String?
    /// Set to present the detail sheet; cleared automatically on dismiss.
    @State private var sheetStation: IdentifiableStation?
    @State private var updatedAtText: String = ""
    @State private var mapStyleOption: MapStyleOption = .standard

    /// Derived from selectedStationID; nil when nothing is selected.
    private var selectedStation: Station? {
        guard let id = selectedStationID else { return nil }
        return appViewModel.stations.first { $0.id == id }
    }

    // MARK: - Body

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedStationID) {
            UserAnnotation()
            ForEach(appViewModel.stations, id: \.id) { station in
                Marker(station.stationName, coordinate: station.coordinate)
                    .tint(Color("BikeBuddyBlue"))
                    .tag(station.id)
            }
        }
        .mapStyle(mapStyleOption.mapStyle)
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .overlay(alignment: .topTrailing) {
            mapControls
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $sheetStation) { wrapper in
            NavigationStack {
                StationDetailView(station: wrapper.station)
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: appViewModel.stationsLastUpdated) { _, _ in
            updateTimestampLabel()
        }
        .onAppear {
            updateTimestampLabel()
        }
    }

    // MARK: - Bottom bar

    /// Shows the selection card when a station is active, otherwise the
    /// last-updated timestamp.  Both swap with an animated transition.
    @ViewBuilder
    private var bottomBar: some View {
        ZStack {
            if let station = selectedStation {
                StationSelectionCard(station: station) {
                    AnalyticsService.sharedInstance.pegUserAction(
                        eventName: Constants.AnalyticEvent.LoadStationDetail,
                        customAttributes: [Constants.AnalyticEventDetail.LoadedFrom: "Map View" as AnyObject]
                    )
                    sheetStation = IdentifiableStation(id: station.id, station: station)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal)
                .padding(.bottom, 8)
            } else if !updatedAtText.isEmpty {
                Text(updatedAtText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity)
                    .padding(.bottom, 8)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedStationID)
    }

    // MARK: - Map controls overlay

    /// Location button + style toggle stacked in the top-trailing corner.
    /// Both use the same glass pill appearance for visual consistency.
    private var mapControls: some View {
        VStack(spacing: 8) {
            // Center on user location
            Button {
                withAnimation {
                    cameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
                }
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            }

            // Toggle map style
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    mapStyleOption = mapStyleOption == .standard ? .satellite : .standard
                }
            } label: {
                Image(systemName: mapStyleOption.toggleIcon)
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.trailing, 10)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func updateTimestampLabel() {
        guard appViewModel.stationsLastUpdated.timeIntervalSince1970 > 0 else { return }
        updatedAtText = StringsService.getStringFor(key: "MapUpdatedAtLabel") + " "
            + Self.timestampFormatter.string(from: appViewModel.stationsLastUpdated)
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

// MARK: - Station selection card

/// Glass card that slides up when a Marker is selected.
/// Shows the station name, bike/dock availability with colour-coded counts,
/// optional distance, and a Details button.
private struct StationSelectionCard: View {

    let station: Station
    let onViewDetail: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Name + distance
            VStack(alignment: .leading, spacing: 4) {
                Text(station.stationName)
                    .font(.headline)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if station.distanceFromUser > 0 {
                    Text(station.approximateDistanceAwayFromUser + " " + StringsService.getStringFor(key: "GeneralAwayLabel"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Bikes count
            availabilityPill(
                count: station.availableBikes,
                icon: "bicycle",
                color: bikesColor
            )

            // Docks count
            availabilityPill(
                count: station.availableDocks,
                icon: "arrow.down.to.line",
                color: .primary
            )

            Button(StringsService.getStringFor(key: "MapStationDetailsButton"), action: onViewDetail)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func availabilityPill(count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(count)")
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
                .monospacedDigit()
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 34)
    }

    private var bikesColor: Color {
        switch station.availableBikes {
        case 0:     .red
        case 1...2: .orange
        default:    .primary
        }
    }
}
