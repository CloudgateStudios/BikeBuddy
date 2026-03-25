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

    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    var body: some View {
        List {
            // MARK: Station name
            Section {
                Text(station.stationName)
                    .font(.headline)
            }

            // MARK: Mini map
            Section {
                StationMiniMapView(station: station)
                    .frame(height: 200)
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
                        .foregroundStyle(Color(red: 0/255, green: 122/255, blue: 255/255))
                }

                Button {
                    prepareAndShare()
                } label: {
                    Label(StringsService.getStringFor(key: "StationDetailShareButton"),
                          systemImage: "square.and.arrow.up")
                        .foregroundStyle(Color(red: 0/255, green: 122/255, blue: 255/255))
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
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
    }

    // MARK: - Actions

    private func openDirections() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.GetDirectionsToStation)

        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(station.latitude, station.longitude), addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = station.stationName
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: options)
    }

    private func prepareAndShare() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.ShareStation)
        shareItems = [station.shareStringDescription]
        showShareSheet = true
    }
}

// MARK: - Mini map

/// MKMapView embedded in SwiftUI showing just this station's pin (no callout).
struct StationMiniMapView: UIViewRepresentable {

    let station: Station

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.isUserInteractionEnabled = false
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // The station is a let — it never changes after the view is created.
        // Guard against the common SwiftUI pattern of calling updateUIView
        // repeatedly so we don't thrash the map with remove/add on every render.
        guard mapView.annotations.isEmpty else { return }
        mapView.addAnnotation(station)
        mapView.showAnnotations([station], animated: false)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            let id = Constants.MapViewReuseIdentifier.StationDetail
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view?.canShowCallout = false
                view?.image = UIImage(named: "mapPin")
            } else {
                view?.annotation = annotation
            }
            return view
        }
    }
}

// MARK: - Share sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
