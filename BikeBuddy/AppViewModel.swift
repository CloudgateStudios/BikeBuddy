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
            // Pre-seed Citi Bike NYC settings
            SettingsService.sharedInstance.saveSetting(
                key: Constants.SettingsKey.BikeServiceName,
                value: "Citi Bike" as AnyObject)
            SettingsService.sharedInstance.saveSetting(
                key: Constants.SettingsKey.BikeServiceCityName,
                value: "New York" as AnyObject)
            SettingsService.sharedInstance.saveSetting(
                key: Constants.SettingsKey.BikeServiceAPIURL,
                value: "https://api.citybik.es/v2/networks/citibike" as AnyObject)
            // Ensure NumberOfClosestStations is saved so getClosestStations doesn't
            // crash with an uninitialised (0) value on a fresh simulator.
            SettingsService.sharedInstance.saveSetting(
                key: Constants.SettingsKey.NumberOfClosestStations,
                value: Constants.SettingsDefault.NumberOfClosestStations as AnyObject)
            loadSettingsState()

            // Pre-populate mock stations so screenshots are network-independent.
            let mockStations = AppViewModel.makeMockStations()
            Stations.sharedInstance.list = mockStations
            stations = mockStations

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

    // MARK: - Screenshot mock data

    #if DEBUG
    private static func makeMockStations() -> [Station] {
        func make(_ id: String, _ name: String, _ bikes: Int, _ docks: Int, _ lat: Double, _ lon: Double) -> Station {
            let s = Station()
            s.id = id
            s.stationName = name
            s.availableBikes = bikes
            s.availableDocks = docks
            s.latitude = lat
            s.longitude = lon
            return s
        }
        return [
            make("m1", "W 41 St & 8 Ave",          12,  8, 40.7563, -73.9914),
            make("m2", "Central Park S & 6 Ave",     3, 17, 40.7652, -73.9769),
            make("m3", "Broadway & W 60 St",          0, 25, 40.7691, -73.9815),
            make("m4", "E 47 St & Park Ave",          7,  2, 40.7552, -73.9757),
            make("m5", "5 Ave & E 34 St",            15,  0, 40.7486, -73.9851),
            make("m6", "W 72 St & Columbus Ave",      9, 11, 40.7773, -73.9809),
            make("m7", "Hudson St & W 13 St",         6,  4, 40.7374, -74.0057),
        ]
    }
    #endif
}
