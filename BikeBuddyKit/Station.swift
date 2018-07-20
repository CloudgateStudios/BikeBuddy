//
//  Station.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import ObjectMapper

/**
 Represents a bike sharing station.
 
 :Implements: MKAnnotation - Allows Station objects to be passed to MapView's for quick annotation loading
 */
public class Station: NSObject, MKAnnotation, Mappable {
    public var id: Int = -1
    public var stationName: String = ""
    public var availableDocks: Int = -1
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var availableBikes: Int = -1
    public var timestamp: String = ""
    public var extraInfo: StationExtra = StationExtra()
    
    public private(set) var distanceFromUser: Double = 0.0
    
    public var approximateDistanceAwayFromUser: String {
        let formatter = MKDistanceFormatter()
        formatter.units = .default
        formatter.unitStyle = .full
        
        let prettyString = "~ " + formatter.string(fromDistance: self.distanceFromUser)
        
        return prettyString
    }
    
    public var streetAddress: String {
        var returnValue: String = ""
        
        if let address = extraInfo.address {
            returnValue = address
        }
        
        return returnValue
    }
    
    public var shareStringDescription: String {
        var returnString = StringsService.getStringFor(key: "StationModelShareStationName") + "\n" + stationName
        
        if streetAddress != "" {
            returnString += "\n\n" + StringsService.getStringFor(key: "StationModelShareAddress") + "\n" + streetAddress
        }
        
        return returnString
    }
    
    @objc public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    public var title: String? {
        return self.stationName
    }
    
    public var subtitle: String? {
        return StringsService.getStringFor(key: "StationModelAnnotationBikes") + ": \(availableBikes) " +  StringsService.getStringFor(key: "StationModelAnnotationOpenDocks") + ": \(availableDocks)"
    }
    
    override init() {
    }
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        availableBikes <- map["free_bikes"]
        availableDocks <- map["empty_slots"]
        stationName <- map["name"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        timestamp <- map["timestamp"]
        extraInfo <- map["extra"]
    }
    
    public func setDistanceFromUser(usersLatitude: Double, usersLongitude: Double) {
        //Only do this if we know the users location
        if usersLatitude != 0 && usersLongitude != 0 {
            let usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
            let stationLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
            
            self.distanceFromUser = usersLocation.distance(from: stationLocation)
        }
    }
}
