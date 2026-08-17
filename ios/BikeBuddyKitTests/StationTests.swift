//
//  StationTests.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/26/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import Testing
import CoreLocation
@testable import BikeBuddyKit

struct StationTests {

    private let testStationName = "Test Station Name"
    private let testLatitude = 41.93250008
    private let testLongitude = -87.65268082
    private let testAvailableBikes = 3
    private let testAvailableDocks = 3

    private func createBasicTestStation() -> Station {
        var newStation = Station()

        newStation.stationName = testStationName
        newStation.latitude = testLatitude
        newStation.longitude = testLongitude
        newStation.availableBikes = testAvailableBikes
        newStation.availableDocks = testAvailableDocks

        return newStation
    }

    @Test func newStationHasEmptyDefaults() {
        let newStation = Station()

        #expect(newStation.stationName.isEmpty)
        #expect(newStation.availableBikes == -1)
        #expect(newStation.availableDocks == -1)
    }

    @Test func fullStationStoresAllValues() {
        let newStation = createBasicTestStation()

        #expect(newStation.stationName == testStationName)
        #expect(newStation.latitude == testLatitude)
        #expect(newStation.longitude == testLongitude)
        #expect(newStation.availableBikes == testAvailableBikes)
        #expect(newStation.availableDocks == testAvailableDocks)
    }

    @Test func streetAddressReadsExtraInfoAddress() {
        var newStation = createBasicTestStation()
        newStation.extraInfo.address = "123 Main St"

        #expect(newStation.streetAddress == "123 Main St")
    }

    // MARK: - Decoding the availability counts

    @Test func decodesBothCountsWhenThePayloadHasThem() throws {
        let json = Data("""
        {"id": "full", "name": "Full Station", "free_bikes": 4, "empty_slots": 9}
        """.utf8)

        let decoded = try JSONDecoder().decode(Station.self, from: json)

        #expect(decoded.availableBikes == 4)
        #expect(decoded.availableDocks == 9)
        #expect(decoded.hasKnownBikeCount)
        #expect(decoded.hasKnownDockCount)
    }

    /// An omitted count used to decode to 0, which is indistinguishable from a station
    /// that is genuinely empty — and the UI paints a real 0 red.
    @Test func anOmittedBikeCountIsUnknownRatherThanZero() throws {
        let json = Data("""
        {"id": "no-bikes-field", "name": "No Bikes Field", "empty_slots": 9}
        """.utf8)

        let decoded = try JSONDecoder().decode(Station.self, from: json)

        #expect(decoded.availableBikes == Station.unknownCount)
        #expect(!decoded.hasKnownBikeCount)
        #expect(decoded.hasKnownDockCount)
    }

    @Test func anOmittedDockCountIsUnknown() throws {
        let json = Data("""
        {"id": "no-docks-field", "name": "No Docks Field", "free_bikes": 4}
        """.utf8)

        let decoded = try JSONDecoder().decode(Station.self, from: json)

        #expect(decoded.availableDocks == Station.unknownCount)
        #expect(!decoded.hasKnownDockCount)
        #expect(decoded.hasKnownBikeCount)
    }

    @Test func aRealZeroCountStaysKnown() throws {
        let json = Data("""
        {"id": "empty", "name": "Empty Station", "free_bikes": 0, "empty_slots": 0}
        """.utf8)

        let decoded = try JSONDecoder().decode(Station.self, from: json)

        #expect(decoded.availableBikes == 0)
        #expect(decoded.hasKnownBikeCount)
        #expect(decoded.hasKnownDockCount)
    }

    // MARK: - Coordinate

    @Test func coordinateMatchesLatitudeAndLongitude() {
        let newStation = createBasicTestStation()
        let expectedCoordinate = CLLocationCoordinate2D(latitude: testLatitude, longitude: testLongitude)

        #expect(newStation.coordinate.latitude == expectedCoordinate.latitude)
        #expect(newStation.coordinate.longitude == expectedCoordinate.longitude)
    }
}
