//
//  Bike_BuddyUITests.swift
//  Bike BuddyUITests
//
//  Created by Tom Arra on 3/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import XCTest

class BikeBuddySnapshotTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        app.launchEnvironment = ["UITest": "1"]
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        
        // Need to wait about 10 seconds for the map to fully load
        sleep(10)
        snapshot("01BasicMap")
        
        tabBarsQuery.buttons["Stations List"].tap()
        snapshot("02StationsList")
        
        tabBarsQuery.buttons["Settings"].tap()
        snapshot("03Settings")
        
    }
    
}
