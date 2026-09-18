//
//  FTUViewModel.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import CoreLocation
import Observation
import BikeBuddyKit

/// Drives the entire First-Time Use navigation flow.
@MainActor
@Observable
class FTUViewModel {

    // MARK: - Navigation steps

    enum Step {
        case welcome
        case locationAccess
        case selectNetwork
        case finished
    }

    /// Drives the NavigationStack in FTUWelcomeView. The steps the user has pushed.
    var path: [Step] = []
    var showLocationDeniedAlert: Bool = false

    private let locationManager = CLLocationManager()
    private var locationDelegate: FTULocationDelegate?

    // MARK: - Navigation helpers

    func goToSelectNetwork() {
        path.append(.selectNetwork)
        // NetworkPickerView loads the list from its own .task. Kicking off a second
        // fetch here just raced it — neither saw Networks.sharedInstance.list
        // populated yet, so both went to the network.
    }

    func goToFinished() {
        path.append(.finished)
    }

    // MARK: - Location

    func requestLocationAccess() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            let delegate = FTULocationDelegate { [weak self] newStatus in
                Task { @MainActor in
                    if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                        self?.goToSelectNetwork()
                    } else {
                        self?.showLocationDeniedAlert = true
                    }
                }
            }
            self.locationDelegate = delegate
            locationManager.delegate = delegate
            locationManager.requestWhenInUseAuthorization()

        case .restricted, .denied:
            showLocationDeniedAlert = true

        case .authorizedWhenInUse, .authorizedAlways:
            goToSelectNetwork()

        @unknown default:
            goToSelectNetwork()
        }
    }

    // MARK: - Networks

    func selectNetwork(_ network: Network) {
        AppViewModel.shared.selectNetwork(network)
        goToFinished()
    }

    func complete() {
        AppViewModel.shared.completeFirstTimeUse()
    }
}

// MARK: - CLLocationManagerDelegate helper

private class FTULocationDelegate: NSObject, CLLocationManagerDelegate {
    private let callback: (CLAuthorizationStatus) -> Void

    init(callback: @escaping (CLAuthorizationStatus) -> Void) {
        self.callback = callback
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        callback(manager.authorizationStatus)
    }
}
