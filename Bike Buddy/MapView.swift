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

/// Replaces MapViewController.
/// Shows all bike stations as map annotations; tapping the callout accessory navigates to StationDetailView.
struct MapView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var selectedStation: Station?
    @State private var navigateToDetail = false
    @State private var updatedAtText: String = ""
    // Deferred so the map frame renders before we ask SwiftUI to lay out
    // potentially 100+ Annotation views simultaneously on first tab switch.
    @State private var annotationsReady = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            mapContent

            if !updatedAtText.isEmpty {
                Text(updatedAtText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 8)
            }
        }
        .navigationTitle(StringsService.getStringFor(key: "MapNavBarTitle"))
        .navigationDestination(isPresented: $navigateToDetail) {
            if let station = selectedStation {
                StationDetailView(station: station)
            }
        }
        .onValueChange(of: appViewModel.stationsLastUpdated) { _ in
            updateTimestampLabel()
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            updateTimestampLabel()
            // Yield one runloop turn so the map frame is on screen before
            // SwiftUI tries to lay out all annotation views at once.
            Task { annotationsReady = true }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }

    // MARK: - Map

    @ViewBuilder
    private var mapContent: some View {
        if #available(iOS 17.0, *) {
            modernMap
        } else {
            legacyMap
        }
    }

    // iOS 17+ Map using the new API
    @available(iOS 17.0, *)
    private var modernMap: some View {
        Map {
            UserAnnotation()
            if annotationsReady {
                ForEach(appViewModel.stations, id: \.id) { station in
                    Annotation(station.stationName, coordinate: station.coordinate) {
                        Button {
                            AnalyticsService.sharedInstance.pegUserAction(
                                eventName: Constants.AnalyticEvent.LoadStationDetail,
                                customAttributes: [Constants.AnalyticEventDetail.LoadedFrom: "Map View" as AnyObject]
                            )
                            selectedStation = station
                            navigateToDetail = true
                        } label: {
                            Image("mapPin")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
        }
    }

    // iOS 16 fallback using UIViewRepresentable
    private var legacyMap: some View {
        LegacyMapViewRepresentable(
            stations: appViewModel.stations,
            onStationTapped: { station in
                AnalyticsService.sharedInstance.pegUserAction(
                    eventName: Constants.AnalyticEvent.LoadStationDetail,
                    customAttributes: [Constants.AnalyticEventDetail.LoadedFrom: "Map View" as AnyObject]
                )
                selectedStation = station
                navigateToDetail = true
            }
        )
        .ignoresSafeArea(edges: .bottom)
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

// MARK: - Legacy MKMapView (iOS 16)

/// UIViewRepresentable wrapping MKMapView for use on iOS 16 where the new Map API
/// doesn't yet support custom annotation views with tap callout accessories.
struct LegacyMapViewRepresentable: UIViewRepresentable {

    let stations: [Station]
    let onStationTapped: (Station) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.onStationTapped = onStationTapped

        // Only update annotations when the station list actually changes
        let currentIDs = Set(mapView.annotations.compactMap { ($0 as? Station)?.id })
        let newIDs = Set(stations.map { $0.id })

        if currentIDs != newIDs {
            mapView.removeAnnotations(mapView.annotations.filter { $0 is Station })
            mapView.addAnnotations(stations)
            if !stations.isEmpty {
                mapView.showAnnotations(stations, animated: true)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onStationTapped: onStationTapped)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {

        var onStationTapped: (Station) -> Void
        // Loaded once and reused across all annotation views.
        private let pinImage = UIImage(named: "mapPin")

        init(onStationTapped: @escaping (Station) -> Void) {
            self.onStationTapped = onStationTapped
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let id = Constants.MapViewReuseIdentifier.FullMap
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)

            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
                view?.canShowCallout = true
                view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                view?.image = pinImage
            } else {
                view?.annotation = annotation
            }
            return view
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            if let station = view.annotation as? Station {
                onStationTapped(station)
            }
        }

        // Needed to make calloutAccessoryControlTapped fire reliably (known iOS bug)
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {}
    }
}
