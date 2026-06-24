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

    var currentStep: Step = .welcome
    var path: [Step] = []
    var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var showLocationDeniedAlert: Bool = false

    // Networks list
    var isLoadingNetworks: Bool = false
    var sortedNetworksList: [(key: String, value: [Network])] = []
    var simpleNetworksList: [Network] = []
    var isSearching: Bool = false
    var searchText: String = "" {
        didSet { applySearch() }
    }

    private let locationManager = CLLocationManager()
    private var locationDelegate: FTULocationDelegate?

    // MARK: - Navigation helpers

    func goToLocationAccess() {
        currentStep = .locationAccess
    }

    func goToSelectNetwork() {
        currentStep = .selectNetwork
        path.append(.selectNetwork)
        loadNetworksIfNeeded()
    }

    func goToFinished() {
        currentStep = .finished
        path.append(.finished)
    }

    // MARK: - Location

    func requestLocationAccess() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            let delegate = FTULocationDelegate { [weak self] newStatus in
                Task { @MainActor in
                    self?.locationAuthorizationStatus = newStatus
                    if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LocationAccessGranted)
                        self?.goToSelectNetwork()
                    } else {
                        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LocationAccessDenied)
                        self?.showLocationDeniedAlert = true
                    }
                }
            }
            self.locationDelegate = delegate
            locationManager.delegate = delegate
            locationManager.requestWhenInUseAuthorization()

        case .restricted, .denied:
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LocationAccessDenied)
            showLocationDeniedAlert = true

        case .authorizedWhenInUse, .authorizedAlways:
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LocationAccessGranted)
            goToSelectNetwork()

        @unknown default:
            goToSelectNetwork()
        }
    }

    // MARK: - Networks

    func loadNetworksIfNeeded() {
        guard Networks.sharedInstance.list.isEmpty else {
            sortedNetworksList = Networks.sharedInstance.networksBySection
            return
        }
        isLoadingNetworks = true
        NetworksDataService.sharedInstance.getAllNetworkData(apiUrl: Constants.CityBikes.NetworksAPI) { [weak self] responseObject, _ in
            Task { @MainActor [weak self] in
                Networks.sharedInstance.list = responseObject
                self?.sortedNetworksList = Networks.sharedInstance.networksBySection
                self?.isLoadingNetworks = false
            }
        }
    }

    func selectNetwork(_ network: Network) {
        AppViewModel.shared.selectNetwork(network)
        AnalyticsService.sharedInstance.pegUserAction(
            eventName: Constants.AnalyticEvent.FTUCitySelected,
            customAttributes: [Constants.AnalyticEventDetail.CitySelected: (network.name ?? "") as AnyObject]
        )
        goToFinished()
    }

    func complete() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.FTUCompleted)
        AppViewModel.shared.completeFirstTimeUse()
    }

    // MARK: - Search

    private func applySearch() {
        let text = searchText
        if text.isEmpty {
            isSearching = false
            sortedNetworksList = Networks.sharedInstance.networksBySection
        } else {
            isSearching = true
            simpleNetworksList = Networks.searchThroughList(searchText: text)
        }
    }

    // MARK: - Network display helper

    func locationString(for network: Network) -> String {
        let city = network.location?.city ?? ""
        let country = CountryCleanupService.sharedInstance.mapCountryCodeToString(
            countryCode: network.location?.country ?? ""
        )
        return "\(city), \(country)"
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
