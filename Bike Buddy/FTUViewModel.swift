//
//  FTUViewModel.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import CoreLocation
import BikeBuddyKit

/// Drives the entire First-Time Use navigation flow.
@MainActor
class FTUViewModel: ObservableObject {

    // MARK: - Navigation steps

    enum Step {
        case welcome
        case locationAccess
        case selectNetwork
        case finished
    }

    @Published var currentStep: Step = .welcome
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var showLocationDeniedAlert: Bool = false

    // Networks list
    @Published var isLoadingNetworks: Bool = false
    @Published var sortedNetworksList: [(key: String, value: [Network])] = []
    @Published var simpleNetworksList: [Network] = []
    @Published var isSearching: Bool = false
    @Published var searchText: String = "" {
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
        loadNetworksIfNeeded()
    }

    func goToFinished() {
        currentStep = .finished
    }

    // MARK: - Location

    func requestLocationAccess() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

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
        if #available(iOS 14.0, *) {
            callback(manager.authorizationStatus)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        callback(status)
    }
}
