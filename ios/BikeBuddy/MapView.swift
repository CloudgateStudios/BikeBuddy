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
    /// Set once the camera has been pointed at the whole network as a stand-in for a
    /// location fix. Provisional: a real fix still gets to replace it.
    @State private var hasFramedNetwork = false

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

    /// What to cluster against: the region the map reported, falling back to wherever
    /// the camera is about to go, so the first frame is not empty while it settles.
    ///
    /// The network-wide fallback is load bearing. With no location fix this used to
    /// return nil, which meant no clusters, which meant the map had no annotations,
    /// which meant `.automatic` had nothing to frame and picked somewhere arbitrary —
    /// and then clustered against *that*, found nothing there either, and stayed
    /// empty. The map could never find the network it was showing.
    private var clusteringRegion: MKCoordinateRegion? {
        if let visibleRegion {
            return visibleRegion
        }

        let coordinate = locationManager.coordinate
        if coordinate.latitude != 0 || coordinate.longitude != 0 {
            return MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: StationClusteringTuning.initialSpanMeters,
                longitudinalMeters: StationClusteringTuning.initialSpanMeters
            )
        }

        return StationClustering.region(enclosing: appViewModel.stations)
    }

    /// The whole selected network, framed. What the map opens on when it has no idea
    /// where the user is.
    ///
    /// On a phone the stations sheet covers the bottom of the map, so a region centred
    /// the usual way puts the middle of the network — and often the user's own end of
    /// it — behind the sheet. Framing it into the strip that is actually visible costs
    /// some zoom but shows the network rather than the half of it that fits.
    private var networkRegion: MKCoordinateRegion? {
        guard let region = StationClustering.region(enclosing: appViewModel.stations) else { return nil }
        guard horizontalSizeClass != .regular else { return region }

        return MapCameraFraming.region(region, framedAbove: StationsSheet.restingFraction)
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
            // The first load usually finishes after this view appears, and until it
            // does there is no network to frame.
            establishCameraIfNeeded()
        }
        .onChange(of: locationManager.coordinate.latitude) { _, _ in
            establishCameraIfNeeded()
        }
        // A station chosen in the panel is usually off screen, or under the sheet.
        // Without this the sidebar and the map would disagree about what is selected.
        .onChange(of: appViewModel.selectedStationID) { _, _ in
            centerOnSelection()
        }
        .onAppear {
            updateTimestampLabel()
            locationManager.startUpdatingLocation()
            establishCameraIfNeeded()
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

    /// The screenshot run switches to satellite through this. The button is an icon
    /// whose symbol changes with the current style, so there is no stable text on it
    /// to find it by.
    static let styleToggleIdentifier = "map.styleToggle"

    /// Likewise for the location button: an icon with no stable text.
    static let locationButtonIdentifier = "map.locationButton"

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
                .accessibilityLabel(Text("MapCenterOnLocationAccessibilityLabel", bundle: .bikeBuddyKit))
                .accessibilityIdentifier(Self.locationButtonIdentifier)

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
                .accessibilityLabel(Text("MapToggleStyleAccessibilityLabel", bundle: .bikeBuddyKit))
                .accessibilityIdentifier(Self.styleToggleIdentifier)
            }
        }
        .padding(.trailing, 10)
    }

    // MARK: - Camera

    /// Points the camera somewhere useful, preferring a walkable radius around the
    /// user and settling for the whole network when their location is unknown.
    ///
    /// Opening on the user rather than the network matters: `.automatic` frames every
    /// annotation, and for a city-wide network that is the entire service area — the
    /// one view in which no individual station is legible. But the network is far
    /// better than the alternative, which was leaving `.automatic` to frame nothing
    /// at all and land somewhere with no relationship to the stations in the list.
    ///
    /// Framing the network is provisional: a location fix arriving later replaces it,
    /// once. Centring on the user is final, so panning away is not undone by the next
    /// location update.
    private func establishCameraIfNeeded() {
        guard !hasCenteredOnUser else { return }

        let coordinate = locationManager.coordinate
        if coordinate.latitude != 0 || coordinate.longitude != 0 {
            hasCenteredOnUser = true
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    latitudinalMeters: StationClusteringTuning.initialSpanMeters,
                    longitudinalMeters: StationClusteringTuning.initialSpanMeters
                ))
            }
            return
        }

        // Stations arrive asynchronously, so this is reached once with nothing to
        // frame and again when the network lands.
        guard !hasFramedNetwork, let networkRegion else { return }

        hasFramedNetwork = true
        withAnimation {
            cameraPosition = .region(networkRegion)
        }
    }

    /// Zooms to the chosen station, and on a phone puts it in the strip above the
    /// sheet rather than behind it.
    ///
    /// This only ever zooms in. Picking a row while looking at a whole network needs
    /// to actually arrive somewhere — holding the span made the station a dot in a
    /// view sixty miles across — but someone already down at street level chose that,
    /// and pulling them back out to a fixed span would undo it. A pin is only
    /// selectable once it has separated from its cluster, so tapping one on the map
    /// already means close enough, and it leaves the camera alone.
    private func centerOnSelection() {
        guard let station = appViewModel.selectedStation else { return }

        let span = MapCameraFraming.selectionSpan(from: visibleRegion?.span)
        let center = horizontalSizeClass == .regular
            ? station.coordinate
            : MapCameraFraming.center(
                station.coordinate,
                clearing: StationsSheet.restingFraction,
                latitudeDelta: span.latitudeDelta
            )

        withAnimation(.easeInOut(duration: 0.35)) {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
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
