//
//  AppViewModelTests.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import Testing
import BikeBuddyKit
@testable import BikeBuddy

/// Mutates `Stations.sharedInstance`, a `@MainActor` singleton, so the suite is
/// serialized and owns that mutation for this bundle. This runs in its own process
/// from `BikeBuddyKitTests`, so it does not contend with the suites over there.
@MainActor
@Suite(.serialized)
struct AppViewModelTests {

    // MARK: - Helpers

    private func station(id: String, latitude: Double, longitude: Double) -> Station {
        var station = Station()
        station.id = id
        station.stationName = "Station \(id)"
        station.latitude = latitude
        station.longitude = longitude
        return station
    }

    /// Spaced north to south so "closest" is unambiguous.
    private func loadStations() {
        Stations.sharedInstance.list = [
            station(id: "far", latitude: 41.95, longitude: -87.65),
            station(id: "near", latitude: 41.90, longitude: -87.65),
            station(id: "middle", latitude: 41.92, longitude: -87.65)
        ]
    }

    /// `init` reads the persisted settings, so anything a test depends on has to be
    /// set after construction rather than before it.
    private func makeViewModel(numberOfClosestStations: Int) -> AppViewModel {
        let viewModel = AppViewModel()
        viewModel.numberOfClosestStations = numberOfClosestStations
        return viewModel
    }

    // MARK: - Closest stations

    @Test func closestStationsAreOrderedByDistance() {
        loadStations()
        let viewModel = makeViewModel(numberOfClosestStations: 3)

        let closest = viewModel.closestStations(latitude: 41.90, longitude: -87.65)

        #expect(closest.map { $0.id } == ["near", "middle", "far"])
    }

    /// The count comes from the user's setting, so the view model has to pass its own
    /// value through rather than relying on whatever the service defaults to.
    @Test func closestStationsHonourTheConfiguredCount() {
        loadStations()
        let viewModel = makeViewModel(numberOfClosestStations: 2)

        #expect(viewModel.closestStations(latitude: 41.90, longitude: -87.65).count == 2)
    }

    @Test func closestStationsFallBackToFeedOrderWithoutALocation() {
        loadStations()
        let viewModel = makeViewModel(numberOfClosestStations: 2)

        let closest = viewModel.closestStations(latitude: 0, longitude: 0)

        #expect(closest.map { $0.id } == ["far", "near"])
    }

    @Test func closestStationsOnAnEmptyListIsEmpty() {
        Stations.sharedInstance.list = []
        let viewModel = makeViewModel(numberOfClosestStations: 5)

        #expect(viewModel.closestStations(latitude: 41.90, longitude: -87.65).isEmpty)
    }
}
