//
//  AppViewModel.swift
//  Bike Buddy
//
//  Created by SwiftUI migration.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import Observation
import CoreLocation
import BikeBuddyKit

/// Central observable object that owns all app state for SwiftUI views.
/// Replaces the notification-centre-based wiring in the UIKit version.
@MainActor
@Observable
class AppViewModel {

    // MARK: - Observed State

    var stations: [Station] = []
    var isLoadingStations: Bool = false
    var stationsLoadError: String?
    var stationsLastUpdated: Date = Date(timeIntervalSince1970: 0)

    var showFirstTimeUse: Bool = false

    // MARK: - Settings (mirrored for reactive UI updates)

    var bikeServiceName: String = ""
    var bikeServiceCityName: String = ""
    var numberOfClosestStations: Int = Constants.SettingsDefault.NumberOfClosestStations
    var appearanceMode: AppearanceMode = .automatic

    // MARK: - Singleton

    static let shared = AppViewModel()

    // MARK: - Init

    private init() {
        loadSettingsState()
        // Support both launch argument (set by XCUITest launchArguments) and
        // environment variable (set by XCUITest launchEnvironment) so the mock-data
        // path works in Debug AND Release build configurations.
        let isScreenshotRun = ProcessInfo.processInfo.arguments.contains("UI_TESTING_SCREENSHOTS")
            || ProcessInfo.processInfo.environment["UI_TESTING_SCREENSHOTS"] == "1"
        if isScreenshotRun {
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
        let rawMode = SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.AppearanceMode)
        appearanceMode = AppearanceMode(rawValue: rawMode) ?? .automatic
    }

    func selectAppearanceMode(_ mode: AppearanceMode) {
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.AppearanceMode, value: mode.rawValue as AnyObject)
        appearanceMode = mode
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
                stationsLoadError = String(localized: "GeneralNoStationsMessageContent", bundle: .bikeBuddyKit)
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
    // Not wrapped in #if DEBUG so it compiles in Release builds used by fastlane snapshot.

    private struct MockStationData {
        let id: String
        let name: String
        let bikes: Int
        let docks: Int
        let latitude: Double
        let longitude: Double
    }

    private static func makeMockStations() -> [Station] {
        let raw: [MockStationData] = [
            MockStationData(id: "m1", name: "W 41 St & 8 Ave", bikes: 12, docks: 8, latitude: 40.7563, longitude: -73.9914),
            MockStationData(id: "m2", name: "Central Park S & 6 Ave", bikes: 3, docks: 17, latitude: 40.7652, longitude: -73.9769),
            MockStationData(id: "m3", name: "Broadway & W 60 St", bikes: 0, docks: 25, latitude: 40.7691, longitude: -73.9815),
            MockStationData(id: "m4", name: "E 47 St & Park Ave", bikes: 7, docks: 2, latitude: 40.7552, longitude: -73.9757),
            MockStationData(id: "m5", name: "5 Ave & E 34 St", bikes: 15, docks: 0, latitude: 40.7486, longitude: -73.9851),
            MockStationData(id: "m6", name: "W 72 St & Columbus Ave", bikes: 9, docks: 11, latitude: 40.7773, longitude: -73.9809),
            MockStationData(id: "m7", name: "Hudson St & W 13 St", bikes: 6, docks: 4, latitude: 40.7374, longitude: -74.0057)
        ]
        return raw.map { data in
            var station = Station()
            station.id = data.id
            station.stationName = data.name
            station.availableBikes = data.bikes
            station.availableDocks = data.docks
            station.latitude = data.latitude
            station.longitude = data.longitude
            return station
        }
    }
}
