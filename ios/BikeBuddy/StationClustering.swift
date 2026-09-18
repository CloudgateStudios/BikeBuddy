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
        let latitudes = stations.map(\.latitude)
        let longitudes = stations.map(\.longitude)

        guard let minLatitude = latitudes.min(), let maxLatitude = latitudes.max(),
              let minLongitude = longitudes.min(), let maxLongitude = longitudes.max() else {
            return MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        }

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLatitude + maxLatitude) / 2,
                longitude: (minLongitude + maxLongitude) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLatitude - minLatitude) * 1.6, 0.004),
                longitudeDelta: max((maxLongitude - minLongitude) * 1.6, 0.004)
            )
        )
    }
}

enum StationClustering {

    /// Cells across the visible span. Ten keeps a cell near a pin's own width at any
    /// zoom, which is what stops neighbours overlapping without collapsing a whole
    /// neighbourhood into a single bubble.
    private static let gridDivisions = 10.0

    /// How far past the visible region to keep clustering, as a fraction of the span.
    /// Stations just off screen still need grouping, or they pop in ungrouped as soon
    /// as the user pans towards them.
    private static let margin = 0.25

    /// Buckets stations into grid cells sized off the visible span, so the pin count
    /// is bounded by the grid rather than by how big the network is.
    static func clusters(for stations: [Station], in region: MKCoordinateRegion) -> [StationCluster] {
        let latitudeSpan = region.span.latitudeDelta
        let longitudeSpan = region.span.longitudeDelta
        guard latitudeSpan > 0, longitudeSpan > 0 else { return [] }

        let minLatitude = region.center.latitude - latitudeSpan * (0.5 + margin)
        let maxLatitude = region.center.latitude + latitudeSpan * (0.5 + margin)
        let minLongitude = region.center.longitude - longitudeSpan * (0.5 + margin)
        let maxLongitude = region.center.longitude + longitudeSpan * (0.5 + margin)

        let cellLatitude = latitudeSpan / gridDivisions
        let cellLongitude = longitudeSpan / gridDivisions

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
        .accessibilityLabel(Text(String(
            format: String(localized: "MapStationClusterLabel", bundle: .bikeBuddyKit),
            count
        )))
    }
}
