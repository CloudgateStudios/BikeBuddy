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

    // MARK: - Spotlight deep link

    private func namedStation(id: String) -> Station {
        var station = Station()
        station.id = id
        station.stationName = "Station \(id)"
        return station
    }

    @Test func noPendingIDResolvesToNoStation() {
        let viewModel = AppViewModel()
        viewModel.stations = [namedStation(id: "abc")]

        #expect(viewModel.deepLinkedStation == nil)
    }

    @Test func aPendingIDResolvesToItsStation() {
        let viewModel = AppViewModel()
        viewModel.stations = [namedStation(id: "abc"), namedStation(id: "def")]

        viewModel.openStationFromSpotlight(id: "def")

        #expect(viewModel.deepLinkedStation?.id == "def")
    }

    /// The cold launch case the whole deferral exists for: the activity arrives before
    /// any station has loaded, so it must resolve later rather than being dropped.
    @Test func aPendingIDSurvivesUntilTheStationsLoad() {
        let viewModel = AppViewModel()

        viewModel.openStationFromSpotlight(id: "abc")

        #expect(viewModel.deepLinkedStation == nil)
        #expect(viewModel.pendingStationID == "abc")

        viewModel.stations = [namedStation(id: "abc")]

        #expect(viewModel.deepLinkedStation?.id == "abc")
    }

    /// Tapping a result for a station the current network does not have. Nothing should
    /// open, and nothing should be left behind.
    @Test func aPendingIDTheLoadedListCannotSatisfyIsDiscarded() {
        let viewModel = AppViewModel()
        viewModel.stations = [namedStation(id: "abc")]

        viewModel.openStationFromSpotlight(id: "not-in-this-network")

        #expect(viewModel.deepLinkedStation == nil)
        #expect(viewModel.pendingStationID == nil)
    }

    /// Guards the surprise this is really about: an id held from a cold launch that the
    /// loaded network turns out not to contain must not sit around and open the sheet
    /// unprompted if that station later appears — e.g. on switching networks back.
    @Test func anUnresolvedPendingIDDoesNotReappearLater() {
        let viewModel = AppViewModel()

        viewModel.openStationFromSpotlight(id: "abc")
        #expect(viewModel.pendingStationID == "abc")

        // A different network loads, without that station.
        viewModel.stations = [namedStation(id: "other")]
        #expect(viewModel.pendingStationID == nil)
        #expect(viewModel.deepLinkedStation == nil)

        // The original network comes back. The stale result must stay closed.
        viewModel.stations = [namedStation(id: "abc")]
        #expect(viewModel.deepLinkedStation == nil)
    }

    @Test func clearingThePendingStationClosesTheLink() {
        let viewModel = AppViewModel()
        viewModel.stations = [namedStation(id: "abc")]
        viewModel.openStationFromSpotlight(id: "abc")
        #expect(viewModel.deepLinkedStation?.id == "abc")

        viewModel.clearPendingStation()

        #expect(viewModel.deepLinkedStation == nil)
        #expect(viewModel.pendingStationID == nil)
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
