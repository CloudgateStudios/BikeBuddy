//
//  Station.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

/**
    Represents a bike sharing station.

    :Implements: MKAnnotation - Allows Station objects to be passed to MapView's for quick annotation loading
*/
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
    var isFavorite: Bool = false
    
    internal private(set) var distanceFromUser: Double = 0.0
    
    var distanceFromUserInMiles: Double {
        get { return distanceFromUser * 0.00062137 }
    }
    
    var shareStringDescription: String {
        get {
            return "Station Name\n" + stationName + "\n\nAddress\n" + streetAddress
        }
    }
    
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
    
    func setDistanceFromUser(usersLatitude: Double, usersLongitude: Double) {
        var usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
        var stationLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        self.distanceFromUser = usersLocation.distanceFromLocation(stationLocation)
    }
}