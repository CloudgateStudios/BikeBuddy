//
//  LocationManager.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

/// Observable wrapper around CLLocationManager.
/// Used by StationsListView and MapView to get the user's current location.
@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.coordinate = loc.coordinate
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            if #available(iOS 14.0, *) {
                self.authorizationStatus = manager.authorizationStatus
            }
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}
