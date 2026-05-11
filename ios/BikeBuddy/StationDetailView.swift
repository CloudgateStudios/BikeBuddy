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

/// Full-screen detail for a single bike station.
/// Layout: full-width interactive map header, glass availability cards,
/// glass actions card. Presents as a push from the station list or as a
/// sheet (with detents) when launched from the map callout.
struct StationDetailView: View {

    let station: Station

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Map header
                Map(initialPosition: .region(MKCoordinateRegion(
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
                .frame(height: 250)

                // MARK: Content
                VStack(spacing: 16) {

                    // Distance (only when known)
                    if station.distanceFromUser > 0 {
                        Text(station.approximateDistanceAwayFromUser
                             + " "
                             + StringsService.getStringFor(key: "GeneralAwayLabel"))
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
                            label: StringsService.getStringFor(key: "StationDetailBikesAvailable"),
                            color: bikesColor
                        )
                        availabilityCard(
                            count: station.availableDocks,
                            icon: "arrow.down.to.line",
                            label: StringsService.getStringFor(key: "StationDetailDocksAvailable"),
                            color: .primary
                        )
                    }

                    // MARK: Actions card
                    VStack(spacing: 0) {
                        Button {
                            openDirections()
                        } label: {
                            Label(StringsService.getStringFor(key: "StationDetailDirectionsButton"),
                                  systemImage: "map.fill")
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
                            Label(StringsService.getStringFor(key: "StationDetailShareButton"),
                                  systemImage: "square.and.arrow.up")
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
        }
        .navigationTitle(station.stationName)
        .navigationBarTitleDisplayMode(.large)
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

    // MARK: - Availability card

    private func availabilityCard(count: Int, icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(count)")
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
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.GetDirectionsToStation)
        let mapItem = MKMapItem(
            location: CLLocation(latitude: station.latitude, longitude: station.longitude),
            address: nil
        )
        mapItem.name = station.stationName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}
