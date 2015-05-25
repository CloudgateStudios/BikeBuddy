//
//  Station.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import MapKit

class Station: NSObject, MKAnnotation {
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
    
    @objc var coordinate : CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
    }
    
    var title : String {
        get { return self.stationName }
    }
    
    var subtitle : String {
        get { return "Bikes: \(availableBikes) Open Docks: \(availableDocks)" }
    }
    
    override init() {
    }
}