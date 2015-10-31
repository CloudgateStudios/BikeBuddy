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
import ObjectMapper

/**
    Represents a bike sharing station.

    :Implements: MKAnnotation - Allows Station objects to be passed to MapView's for quick annotation loading
*/
class Station: NSObject, MKAnnotation, Mappable {
    var id: Int = -1
    var stationName: String = ""
    var availableDocks: Int = -1
    var totalDocks: Int = -1
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var statusValue: String = ""
    var statusKey: Int = -1
    var availableBikes: Int = -1
    var addressLineOne: String = ""
    var addressLineTwo: String = ""
    var city: String = ""
    var postalCode: String = ""
    var location: String = ""
    var altitude: String = ""
    var testStation: Bool = false
    var lastCommunicationTime: String = ""
    var landMark: String = ""
    
    internal private(set) var distanceFromUser: Double = 0.0
    
    var approximateDistanceAwayFromUser: String {
        get {
            let formatter = MKDistanceFormatter()
            formatter.units = .Default
            formatter.unitStyle = .Full
            
            let prettyString = "~ " + formatter.stringFromDistance(self.distanceFromUser)
            
            return prettyString
        }
    }
    
    var streetAddress: String {
        get {
            return addressLineOne + " " + addressLineTwo
        }
    }
    
    var shareStringDescription: String {
        get {
            var returnString = NSLocalizedString("StationModelShareStationName", comment: "") + "\n" + stationName
            
            if(streetAddress != "") {
                returnString += "\n\n" + NSLocalizedString("StationModelShareAddress", comment: "") + "\n" + streetAddress
            }
            
            return returnString
        }
    }
    
    @objc var coordinate : CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
    }
    
    var title : String? {
        get { return self.stationName }
    }
    
    var subtitle : String? {
        get { return NSLocalizedString("StationModelAnnotationBikes", comment: "") + ": \(availableBikes) " +  NSLocalizedString("StationModelAnnotationOpenDocks", comment: "") + ": \(availableDocks)" }
    }
    
    override init() {
    }
    
    required convenience init?(_ map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        stationName <- map["stationName"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        availableBikes <- map["availableBikes"]
        availableDocks <- map["availableDocks"]
        addressLineOne <- map["stAddress1"]
        addressLineTwo <- map["stAddress2"]
        
    }
    
    func setDistanceFromUser(usersLatitude: Double, usersLongitude: Double) {
        let usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
        let stationLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        self.distanceFromUser = usersLocation.distanceFromLocation(stationLocation)
    }
}