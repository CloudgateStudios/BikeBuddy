//
//  StationTests.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/26/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import XCTest
import CoreLocation
@testable import BikeBuddyKit

class StationTests: XCTestCase {
    
     private let testStationName = "Test Station Name"
     private let testLatitude = 41.93250008
     private let testLongitude = -87.65268082
     private let testAvailableBikes = 3
     private let testAvailableDocks = 3
     
     override func setUp() {
        super.setUp()
     }
     
     override func tearDown() {
        super.tearDown()
     }
     
     private func createBasicTestStation() -> Station {
         let newStation = Station()
        
         newStation.stationName = testStationName
         newStation.latitude = testLatitude
         newStation.longitude = testLongitude
         newStation.availableBikes = testAvailableBikes
         newStation.availableDocks = testAvailableDocks
        
         return newStation
     }
     
     func testCreateBasicStation() {
         let newStation = Station()
        
         XCTAssertNotNil(newStation, "Object should not be nil")
     }
     
     func testCreateFullStation() {
         let newStation = createBasicTestStation()
        
         XCTAssertEqual(newStation.stationName, testStationName, "Station name should be \(testStationName)")
         XCTAssertEqual(newStation.latitude, testLatitude, "Station latitude should be \(testLatitude)")
         XCTAssertEqual(newStation.longitude, testLongitude, "Station longitude should be \(testLongitude)")
         XCTAssertEqual(newStation.availableBikes, testAvailableBikes, "Station available bikes should be \(testAvailableBikes)")
         XCTAssertEqual(newStation.availableDocks, testAvailableDocks, "Station available docks should be \(testAvailableDocks)")
     }
     
     func testStationTitleForMapAnnotation() {
         let newStation = createBasicTestStation()
        
         XCTAssertEqual(newStation.title, testStationName, "Station title should match \(testStationName)")
     }
     
     func testStationCoordinate() {
         let newStation = createBasicTestStation()
         let expectedCoordinate = CLLocationCoordinate2D(latitude: testLatitude, longitude: testLongitude)
         
         XCTAssertEqual(newStation.coordinate.longitude, expectedCoordinate.longitude, "Coordinate longitude should be \(expectedCoordinate.longitude)")
         XCTAssertEqual(newStation.coordinate.latitude, expectedCoordinate.latitude, "Coordinate latitude should be \(expectedCoordinate.latitude)")
     }
}
