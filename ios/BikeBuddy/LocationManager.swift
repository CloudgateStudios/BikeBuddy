//
//  LocationManager.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import CoreLocation
import Observation

/// Observable wrapper around CLLocationManager.
/// Used by StationsListView and MapView to get the user's current location.
@MainActor
@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {

    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Only publish a new coordinate when the user moves at least 10 metres.
        // Without this, GPS fires multiple times per second and causes the entire
        // StationsListView (including the closest-stations sort) to re-render
        // on every tick, which is the primary source of UI sluggishness.
        locationManager.distanceFilter = 10

        authorizationStatus = locationManager.authorizationStatus
    }

    /// Prompts for permission. Only does anything while the status is notDetermined —
    /// once the user has answered, iOS ignores this and Settings is the only route back.
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// True when we cannot produce distances: either the user has said no, or they have
    /// not been asked yet outside of first-time use.
    var canProvideLocation: Bool {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
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
            self.authorizationStatus = self.locationManager.authorizationStatus
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
}
