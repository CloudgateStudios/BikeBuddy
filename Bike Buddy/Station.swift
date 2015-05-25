//
//  Station.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

class Station {
    var id: Int = -1
    var stationName: String = ""
    var availableDocks: Int = -1
    var totalDocks: Int = -1
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var statusValue: String = ""
    var statusKey: Int = -1
    var availableBikes: Int = -1
    var streetAddress: String = ""
    var city: String = ""
    var postalCode: String = ""
    var location: String = ""
    var altitude: String = ""
    var testStation: Bool = false
    var lastCommunicationTime: String = ""
    var landMark: String = ""
    
    init() {
    }
}