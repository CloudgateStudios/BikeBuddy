//
//  StationTests.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/26/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

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
        let newStation = Station()

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

    @Test func titleMatchesStationName() {
        let newStation = createBasicTestStation()

        #expect(newStation.title == testStationName)
    }

    @Test func coordinateMatchesLatitudeAndLongitude() {
        let newStation = createBasicTestStation()
        let expectedCoordinate = CLLocationCoordinate2D(latitude: testLatitude, longitude: testLongitude)

        #expect(newStation.coordinate.latitude == expectedCoordinate.latitude)
        #expect(newStation.coordinate.longitude == expectedCoordinate.longitude)
    }
}
