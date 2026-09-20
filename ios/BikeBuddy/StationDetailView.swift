//
//  StationDetailView.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import SwiftUI
import MapKit
import BikeBuddyKit

/// Detail for a single bike station: map header, availability cards, actions.
///
/// Pushed inside the stations sheet on a phone, where the live map is already on
/// screen behind it — see `showsMapHeader`.
struct StationDetailView: View {

    let station: Station

    /// Whether to draw the small map at the top.
    ///
    /// Off when this is presented over the real map, which is the phone's whole
    /// layout: a static 250pt map of the same station, laid over an interactive one
    /// showing the same pin, is a picture of what the user is already looking at. It
    /// also costs a second MKMapView for the privilege.
    var showsMapHeader: Bool = true

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Map header
                mapHeader

                // MARK: Content
                VStack(spacing: 16) {

                    // Distance (only when known)
                    if station.distanceFromUser > 0 {
                        Text(station.approximateDistanceAwayFromUser
                             + " "
                             + String(localized: "GeneralAwayLabel", bundle: .bikeBuddyKit))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !station.streetAddress.isEmpty {
                        Text(station.streetAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: Availability cards
                    HStack(spacing: 16) {
                        availabilityCard(
                            count: station.availableBikes,
                            icon: "bicycle",
                            label: String(localized: "StationDetailBikesAvailable", bundle: .bikeBuddyKit),
                            color: bikesColor
                        )
                        availabilityCard(
                            count: station.availableDocks,
                            icon: "arrow.down.to.line",
                            label: String(localized: "StationDetailDocksAvailable", bundle: .bikeBuddyKit),
                            color: .primary
                        )
                    }

                    // MARK: Actions card
                    VStack(spacing: 0) {
                        Button {
                            openDirections()
                        } label: {
                            Label { Text("StationDetailDirectionsButton", bundle: .bikeBuddyKit) } icon: { Image(systemName: "map.fill") }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)

                        Divider()
                            .padding(.leading, 16)

                        ShareLink(
                            item: station.shareStringDescription,
                            subject: Text(station.stationName)
                        ) {
                            Label { Text("StationDetailShareButton", bundle: .bikeBuddyKit) } icon: { Image(systemName: "square.and.arrow.up") }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
            .adaptiveContentWidth()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(station.stationName)
        .navigationBarTitleDisplayMode(showsMapHeader ? .large : .inline)
        .userActivity(Constants.UserActivity.StationActivityTypeIdentifier) { activity in
            activity.title = station.stationName
            let userInfo: [String: Any] = ["stationId": station.id, "stationName": station.stationName]
            activity.addUserInfoEntries(from: userInfo)
            activity.requiredUserInfoKeys = ["stationId", "stationName"]
            activity.isEligibleForHandoff = false
            activity.isEligibleForSearch = true
            activity.isEligibleForPublicIndexing = true
            var keywords = station.stationName.components(separatedBy: " ")
            keywords.append(station.streetAddress)
            activity.keywords = Set(keywords)
            activity.becomeCurrent()
        }
    }

    // MARK: - Map header

    /// Bleeds to the edges on a phone, as it always has. At regular width the content
    /// below sits in a capped column, so a full-bleed map would be a band the column
    /// no longer lines up with — it joins the column instead, and takes the extra
    /// height that capping the column frees up.
    @ViewBuilder
    private var mapHeader: some View {
        if showsMapHeader {
            sizedMap
        }
    }

    @ViewBuilder
    private var sizedMap: some View {
        let map = Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
            latitudinalMeters: 500,
            longitudinalMeters: 500
        ))) {
            Marker(station.stationName, coordinate: CLLocationCoordinate2D(
                latitude: station.latitude,
                longitude: station.longitude
            ))
            .tint(Color("BikeBuddyBlue"))
        }

        if isRegularWidth {
            map
                .containerRelativeFrame(.vertical) { height, _ in
                    height * AdaptiveLayout.detailMapHeightFractionRegular
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.top, 16)
        } else {
            map.frame(height: AdaptiveLayout.detailMapHeightCompact)
        }
    }

    // MARK: - Availability card

    @ViewBuilder
    private func availabilityCard(count: Int, icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Group {
                if count < 0 {
                    Text(verbatim: "—")
                } else {
                    Text(count, format: .number)
                }
            }
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var bikesColor: Color {
        switch station.availableBikes {
        case 0:     .red
        case 1...2: .orange
        default:    .primary
        }
    }

    // MARK: - Actions

    private func openDirections() {
        station.openInMaps()
    }
}
