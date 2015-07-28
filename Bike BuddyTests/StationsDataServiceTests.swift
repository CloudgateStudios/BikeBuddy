//
//  StationsDataServiceTests.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/26/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import XCTest

class StationsDataServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        var result = StationsDataService.sharedInstance.loadStationDataFromFile("Divvy_API_Response.json")
        
        XCTAssertNotNil(result, "Result is nil, should have at least some Stations objects in it.")
        XCTAssertEqual(result.count, 466, "Result should be 466 long")
    }

}