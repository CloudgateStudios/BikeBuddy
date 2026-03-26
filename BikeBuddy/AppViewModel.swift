//
//  AppViewModel.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import BikeBuddyKit

/// Central ObservableObject that owns all app state for SwiftUI views.
/// Replaces the notification-centre-based wiring in the UIKit version.
@MainActor
class AppViewModel: ObservableObject {

    // MARK: - Published State

    @Published var stations: [Station] = []
    @Published var isLoadingStations: Bool = false
    @Published var stationsLoadError: String?
    @Published var stationsLastUpdated: Date = Date(timeIntervalSince1970: 0)

    @Published var showFirstTimeUse: Bool = false

    // MARK: - Settings (mirrored for reactive UI updates)

    @Published var bikeServiceName: String = ""
    @Published var bikeServiceCityName: String = ""
    @Published var numberOfClosestStations: Int = Constants.SettingsDefault.NumberOfClosestStations

    // MARK: - Singleton

    static let shared = AppViewModel()

    // MARK: - Init

    private init() {
        loadSettingsState()
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING_SCREENSHOTS") {
            // Pre-seed Citi Bike NYC so the app has a network to load without FTU
            if bikeServiceName.isEmpty {
                SettingsService.sharedInstance.saveSetting(
                    key: Constants.SettingsKey.BikeServiceName,
                    value: "Citi Bike" as AnyObject)
                SettingsService.sharedInstance.saveSetting(
                    key: Constants.SettingsKey.BikeServiceCityName,
                    value: "New York" as AnyObject)
                SettingsService.sharedInstance.saveSetting(
                    key: Constants.SettingsKey.BikeServiceAPIURL,
                    value: "https://api.citybik.es/v2/networks/citibike" as AnyObject)
                loadSettingsState()
            }
            showFirstTimeUse = false
            return
        }
        #endif
        // Fire FTU if the user has never completed setup
        if !SettingsService.sharedInstance.getSettingAsBool(key: Constants.SettingsKey.FirstTimeUseCompleted) {
            showFirstTimeUse = true
        }
    }

    // MARK: - Settings helpers

    func loadSettingsState() {
        bikeServiceName = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceName)
        bikeServiceCityName = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceCityName)
        numberOfClosestStations = SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations)
        if numberOfClosestStations == 0 {
            numberOfClosestStations = Constants.SettingsDefault.NumberOfClosestStations
        }
    }

    func completeFirstTimeUse() {
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.FirstTimeUseCompleted, value: true as AnyObject)
        loadSettingsState()
        showFirstTimeUse = false
        // Refresh stations with newly selected network
        Task { await refreshStations() }
    }

    func selectNetwork(_ network: Network) {
        guard let href = network.href else { return }
        let builtAPIURL = Constants.CityBikes.BaseAPIURL + href
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: (network.location?.city ?? "") as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: (network.name ?? "") as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: builtAPIURL as AnyObject)
        loadSettingsState()
    }

    func selectNumberOfClosestStations(_ count: Int) {
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.NumberOfClosestStations, value: count as AnyObject)
        numberOfClosestStations = count
    }

    // MARK: - Stations loading

    func refreshStationsIfNeeded() async {
        if stations.isEmpty || Stations.shouldBeUpdated() {
            await refreshStations()
        }
    }

    func refreshStations() async {
        let apiUrl = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)
        guard !apiUrl.isEmpty else { return }

        isLoadingStations = true
        stationsLoadError = nil

        do {
            let result = try await StationsDataService.sharedInstance.getAllStationData(apiUrl: apiUrl)
            if result.isEmpty {
                stationsLoadError = StringsService.getStringFor(key: "GeneralNoStationsMessageContent")
            } else {
                Stations.sharedInstance.list = result
                stations = result
                stationsLastUpdated = Date()
            }
        } catch {
            stationsLoadError = error.localizedDescription
        }

        isLoadingStations = false
    }

    // MARK: - Closest stations helper (location-aware)

    func closestStations(latitude: Double, longitude: Double) -> [Station] {
        return Stations.getClosestStations(latitude: latitude, longitude: longitude, numberOfStations: numberOfClosestStations)
    }
}
