//
//  MapView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
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

// MARK: - Map view

/// Full-screen map showing nearby bike stations, grouped into count bubbles where
/// they are too close together to draw separately.
/// Tapping a Marker slides up a glass selection card with availability counts.
/// Tapping "Details" on the card presents StationDetailView as a sheet.
struct MapView: View {

    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var locationManager = LocationManager()

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var updatedAtText: String = ""
    @State private var mapStyleOption: MapStyleOption = .standard
    /// What the map last told us it is showing. Clustering is computed against this
    /// rather than the whole network, so the work scales with what is on screen.
    @State private var visibleRegion: MKCoordinateRegion?
    /// Set once the camera has been moved to the user, so a later location update
    /// does not yank the map back while they are panning around.
    @State private var hasCenteredOnUser = false

    /// Derived from selectedStationID; nil when nothing is selected. Populates
    /// `distanceFromUser` on the returned copy when the user's location is known
    /// (Station is a value type, so this doesn't mutate the shared list).
    private var selectedStation: Station? {
        appViewModel.selectedStation
    }

    // MARK: - Clustering

    /// The pins to draw right now. A network the size of Citi Bike NYC is ~2,400
    /// stations; drawing a Marker each covered the city in overlapping pins and gave
    /// the map nothing to say. Grouping by grid cell keeps the pin count bounded by
    /// the grid rather than the network.
    private var visibleClusters: [StationCluster] {
        guard let clusteringRegion else { return [] }

        return StationClustering.clusters(for: appViewModel.stations, in: clusteringRegion)
    }

    /// What to cluster against: the region the map reported, falling back to the area
    /// we are about to centre on so the first frame is not empty while we wait for
    /// the camera to settle.
    private var clusteringRegion: MKCoordinateRegion? {
        if let visibleRegion {
            return visibleRegion
        }

        let coordinate = locationManager.coordinate
        guard coordinate.latitude != 0 || coordinate.longitude != 0 else { return nil }

        return MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: StationClusteringTuning.initialSpanMeters,
            longitudinalMeters: StationClusteringTuning.initialSpanMeters
        )
    }

    // MARK: - Body

    var body: some View {
        @Bindable var appViewModel = appViewModel

        // The controls sit in a ZStack beside the map rather than in an overlay on it.
        // An overlay inherits the map's bounds, and the map deliberately ignores the
        // safe area — which put the location button under the status bar now that
        // there is no tab bar or nav bar holding it down.
        return ZStack(alignment: .topTrailing) {
            map
            placedMapControls
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var map: some View {
        @Bindable var appViewModel = appViewModel

        Map(position: $cameraPosition, selection: $appViewModel.selectedStationID) {
            UserAnnotation()
            ForEach(visibleClusters) { cluster in
                if let station = cluster.singleStation {
                    Marker(station.stationName, coordinate: station.coordinate)
                        .tint(Color("BikeBuddyBlue"))
                        .tag(station.id)
                } else {
                    // A group gets custom content rather than a Marker, because a
                    // Marker cannot show the count that makes the bubble readable.
                    Annotation("", coordinate: cluster.coordinate) {
                        StationClusterBubble(count: cluster.count) {
                            zoom(into: cluster)
                        }
                    }
                    .annotationTitles(.hidden)
                }
            }
        }
        .mapStyle(mapStyleOption.mapStyle)
        // Vertical only. Ignoring every edge let the map — and with it the selection
        // card riding in its bottom safe-area inset — run underneath the split view's
        // sidebar, which quietly ate the left half of the card.
        .ignoresSafeArea(edges: .vertical)
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .onChange(of: appViewModel.stationsLastUpdated) { _, _ in
            updateTimestampLabel()
        }
        .onChange(of: locationManager.coordinate.latitude) { _, _ in
            centerOnUserIfNeeded()
        }
        // A station chosen in the panel is usually off screen, or under the sheet.
        // Without this the sidebar and the map would disagree about what is selected.
        .onChange(of: appViewModel.selectedStationID) { _, _ in
            centerOnSelection()
        }
        .onAppear {
            updateTimestampLabel()
            locationManager.startUpdatingLocation()
            centerOnUserIfNeeded()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }

    // MARK: - Bottom bar

    /// Shows the selection card when a station is active, otherwise the
    /// last-updated timestamp.  Both swap with an animated transition.
    ///
    /// Only regular width draws the card. On a phone the stations sheet sits over this
    /// exact spot and pushes the selected station's detail itself, so a card here
    /// would be a second copy of the same thing, hidden behind the first.
    @ViewBuilder
    private var bottomBar: some View {
        ZStack {
            if let station = selectedStation, horizontalSizeClass == .regular {
                StationSelectionCard(station: station) {
                    appViewModel.selectedStationID = nil
                }
                .adaptiveContentWidth()
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
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: appViewModel.selectedStationID)
    }

    // MARK: - Map controls overlay

    /// Keeps the controls clear of the top of the display whether or not the system
    /// has reserved anything up there.
    ///
    /// Most iPhones report a top safe area inset of 50-60pt for the status bar, so a
    /// small padding on top of it lands the buttons comfortably. A folded iPhone
    /// unfolded reports `top 0` — its status bar runs down the *trailing* edge
    /// instead — and the same small padding put a 44pt button hard against the
    /// rounded corner. So the padding is whatever it takes to reach a minimum margin
    /// from the edge, and never less than the breathing room the inset already buys.
    private static let minimumControlsTopMargin: CGFloat = 28

    private var placedMapControls: some View {
        GeometryReader { proxy in
            mapControls
                .padding(.top, max(8, Self.minimumControlsTopMargin - proxy.safeAreaInsets.top))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }

    /// Location button + style toggle stacked in the top-trailing corner.
    /// Both float over the map as interactive Liquid Glass pills. They share a
    /// `GlassEffectContainer` so the system renders the two effects together; the
    /// container spacing is kept below the stack spacing so the pills stay distinct
    /// at rest rather than blending into a single shape.
    private var mapControls: some View {
        GlassEffectContainer(spacing: 4) {
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
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
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
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
                }
            }
        }
        .padding(.trailing, 10)
    }

    // MARK: - Camera

    /// Opens on the user rather than on the whole network. `.automatic` frames every
    /// annotation, which for a city-wide network meant the first thing the tab showed
    /// was the entire service area — the one view in which no station is legible.
    /// Runs once, so panning away is not undone by the next location update.
    private func centerOnUserIfNeeded() {
        guard !hasCenteredOnUser else { return }

        let coordinate = locationManager.coordinate
        guard coordinate.latitude != 0 || coordinate.longitude != 0 else { return }

        hasCenteredOnUser = true
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: StationClusteringTuning.initialSpanMeters,
                longitudinalMeters: StationClusteringTuning.initialSpanMeters
            ))
        }
    }

    /// Brings the chosen station into view without changing how far in the user is
    /// zoomed — re-framing the map under them because they tapped a row in a list is
    /// disorienting, and they may have zoomed deliberately.
    private func centerOnSelection() {
        guard let station = appViewModel.selectedStation else { return }

        let span = visibleRegion?.span ?? MKCoordinateSpan(
            latitudeDelta: StationClusteringTuning.minimumZoomSpan,
            longitudeDelta: StationClusteringTuning.minimumZoomSpan
        )

        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(MKCoordinateRegion(center: station.coordinate, span: span))
        }
    }

    /// Tightens onto the cluster's own footprint instead of stepping a fixed amount,
    /// so one tap breaks the group apart whether it spans a block or half the city.
    private func zoom(into cluster: StationCluster) {
        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(cluster.boundingRegion)
        }
    }

    // MARK: - Helpers

    private func updateTimestampLabel() {
        guard appViewModel.stationsLastUpdated.timeIntervalSince1970 > 0 else { return }
        // `.shortened` follows the device's locale and 24-hour setting. A fixed
        // "h:mm a" format forced 12-hour AM/PM on everyone.
        let time = appViewModel.stationsLastUpdated.formatted(date: .omitted, time: .shortened)
        updatedAtText = String(localized: "MapUpdatedAtLabel", bundle: .bikeBuddyKit) + " " + time
    }
}
