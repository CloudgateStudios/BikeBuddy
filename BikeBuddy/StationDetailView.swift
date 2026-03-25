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

/// Replaces StationDetailTableViewController.
struct StationDetailView: View {

    let station: Station

    var body: some View {
        List {
            // MARK: Station name
            Section {
                Text(station.stationName)
                    .font(.headline)
            }

            // MARK: Mini map
            Section {
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
                .frame(height: 200)
                .disabled(true)
                .listRowInsets(EdgeInsets())
            }

            // MARK: Distance (only when known)
            if station.distanceFromUser > 0 {
                Section {
                    Text(station.approximateDistanceAwayFromUser + " " + StringsService.getStringFor(key: "GeneralAwayLabel"))
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Availability
            Section {
                HStack {
                    Text(StringsService.getStringFor(key: "StationDetailBikesAvailable"))
                    Spacer()
                    Text(NumberFormatter.localizedString(from: station.availableBikes as NSNumber, number: .none))
                        .fontWeight(.semibold)
                }
                HStack {
                    Text(StringsService.getStringFor(key: "StationDetailDocksAvailable"))
                    Spacer()
                    Text(NumberFormatter.localizedString(from: station.availableDocks as NSNumber, number: .none))
                        .fontWeight(.semibold)
                }
            }

            // MARK: Actions
            Section {
                Button {
                    openDirections()
                } label: {
                    Label(StringsService.getStringFor(key: "StationDetailDirectionsButton"),
                          systemImage: "map.fill")
                }

                ShareLink(
                    item: station.shareStringDescription,
                    subject: Text(station.stationName)
                ) {
                    Label(StringsService.getStringFor(key: "StationDetailShareButton"),
                          systemImage: "square.and.arrow.up")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(StringsService.getStringFor(key: "StationDetailNavBarTitle"))
        .navigationBarTitleDisplayMode(.inline)
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
