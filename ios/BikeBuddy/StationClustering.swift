//
//  StationClustering.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
import BikeBuddyKit

// MARK: - Tuning

/// Every value worth adjusting after seeing the map against a real network, in one
/// place. These stay in the app target rather than moving to BikeBuddyKit's
/// Constants: they describe how this view draws pins, which is meaningless to the
/// framework's models and services, and each only reads sensibly beside the
/// algorithm it feeds.
enum StationClusteringTuning {

    /// Cells across the visible span. Ten keeps a cell near a pin's own width at any
    /// zoom, which is what stops neighbours overlapping without collapsing a whole
    /// neighbourhood into a single bubble. Raise it for more, smaller groups.
    static let gridDivisions = 10.0

    /// How far past the visible region to keep clustering, as a fraction of the span.
    /// Stations just off screen still need grouping, or they pop in ungrouped as soon
    /// as the user pans towards them.
    static let offscreenMargin = 0.25

    /// How much room to leave around a cluster's members when zooming to it. 1.0 would
    /// put the outermost pins exactly on the edge.
    static let zoomPadding = 1.6

    /// Smallest span a zoom-to-cluster will produce, in degrees (~450m). Without a
    /// floor, tapping a tight group jumps straight past street level.
    static let minimumZoomSpan = 0.004

    /// Span used when a cluster somehow has no coordinates to measure. Only reachable
    /// if `stations` is empty, which the clustering never produces.
    static let fallbackZoomMeters: CLLocationDistance = 500

    /// How wide a view to open on once the user's location is known. Roughly a
    /// walkable radius, which is the question the map tab answers.
    static let initialSpanMeters: CLLocationDistance = 2000

    /// How close to settle when a single station is chosen, in degrees (~650m).
    /// Close enough to read the cross streets it sits on, wide enough to see what is
    /// around it and walk there.
    static let selectedStationSpan = 0.006
}

// MARK: - Station clustering

/// A group of stations that sit in the same grid cell at the current zoom, and so
/// share one pin. A cluster of one is drawn as the station's own Marker.
struct StationCluster: Identifiable {

    let id: String
    let coordinate: CLLocationCoordinate2D
    let stations: [Station]

    var count: Int { stations.count }

    /// The station to draw as a real Marker, when this cluster holds only one.
    var singleStation: Station? { stations.count == 1 ? stations.first : nil }

    /// A region snug around the members, padded so they do not sit on the edge and
    /// floored so a tight group does not jump straight to street level.
    var boundingRegion: MKCoordinateRegion {
        StationClustering.region(enclosing: stations) ?? MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: StationClusteringTuning.fallbackZoomMeters,
            longitudinalMeters: StationClusteringTuning.fallbackZoomMeters
        )
    }
}

enum StationClustering {

    /// Buckets stations into grid cells sized off the visible span, so the pin count
    /// is bounded by the grid rather than by how big the network is.
    /// The region that just contains these stations, with a little room around them.
    ///
    /// Shared by a cluster zooming to its own members and by the map framing a whole
    /// network when it has no better idea where to look. Nil for an empty list, which
    /// is the caller's cue that there is nothing to frame yet.
    static func region(enclosing stations: [Station]) -> MKCoordinateRegion? {
        let latitudes = stations.map(\.latitude)
        let longitudes = stations.map(\.longitude)

        guard let minLatitude = latitudes.min(), let maxLatitude = latitudes.max(),
              let minLongitude = longitudes.min(), let maxLongitude = longitudes.max() else {
            return nil
        }

        let padding = StationClusteringTuning.zoomPadding
        let minimumSpan = StationClusteringTuning.minimumZoomSpan

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLatitude + maxLatitude) / 2,
                longitude: (minLongitude + maxLongitude) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLatitude - minLatitude) * padding, minimumSpan),
                longitudeDelta: max((maxLongitude - minLongitude) * padding, minimumSpan)
            )
        )
    }

    static func clusters(for stations: [Station], in region: MKCoordinateRegion) -> [StationCluster] {
        let latitudeSpan = region.span.latitudeDelta
        let longitudeSpan = region.span.longitudeDelta
        guard latitudeSpan > 0, longitudeSpan > 0 else { return [] }

        let halfSpan = 0.5 + StationClusteringTuning.offscreenMargin

        let minLatitude = region.center.latitude - latitudeSpan * halfSpan
        let maxLatitude = region.center.latitude + latitudeSpan * halfSpan
        let minLongitude = region.center.longitude - longitudeSpan * halfSpan
        let maxLongitude = region.center.longitude + longitudeSpan * halfSpan

        let cellLatitude = latitudeSpan / StationClusteringTuning.gridDivisions
        let cellLongitude = longitudeSpan / StationClusteringTuning.gridDivisions

        var buckets = [String: [Station]]()

        for station in stations {
            guard station.latitude >= minLatitude, station.latitude <= maxLatitude,
                  station.longitude >= minLongitude, station.longitude <= maxLongitude else {
                continue
            }

            // Index off absolute coordinates rather than an offset from the region's
            // corner, so cell boundaries stay put as the user pans and pins do not
            // regroup under the finger.
            let latitudeIndex = Int((station.latitude / cellLatitude).rounded(.down))
            let longitudeIndex = Int((station.longitude / cellLongitude).rounded(.down))

            buckets["\(latitudeIndex):\(longitudeIndex)", default: []].append(station)
        }

        return buckets.map { key, members in
            // A lone station keeps its own id so it holds identity across a zoom that
            // changes which cell it lands in; a group is identified by the cell.
            let identifier = members.count == 1 ? "station:\(members[0].id)" : "cell:\(key)"

            let latitude = members.reduce(0) { $0 + $1.latitude } / Double(members.count)
            let longitude = members.reduce(0) { $0 + $1.longitude } / Double(members.count)

            return StationCluster(
                id: identifier,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                stations: members
            )
        }
    }
}

/// The pin drawn for a group of stations: how many, tappable to zoom in.
struct StationClusterBubble: View {

    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(count, format: .number)
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .frame(minWidth: 34, minHeight: 34)
                .background(Color("BikeBuddyBlue"), in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2))
                .shadow(radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .hoverEffect(.lift)
        .accessibilityLabel(Text(String(
            format: String(localized: "MapStationClusterLabel", bundle: .bikeBuddyKit),
            count
        )))
    }
}
