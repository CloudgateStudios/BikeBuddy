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
    public var totalDocks: Int = -1
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var statusValue: String = ""
    public var statusKey: Int = -1
    public var availableBikes: Int = -1
    public var addressLineOne: String = ""
    public var addressLineTwo: String = ""
    public var city: String = ""
    public var postalCode: String = ""
    public var location: String = ""
    public var altitude: String = ""
    public var testStation: Bool = false
    public var lastCommunicationTime: String = ""
    public var landMark: String = ""
    
    public private(set) var distanceFromUser: Double = 0.0
    
    public var approximateDistanceAwayFromUser: String {
        get {
            let formatter = MKDistanceFormatter()
            formatter.units = .default
            formatter.unitStyle = .full
            
            let prettyString = "~ " + formatter.string(fromDistance: self.distanceFromUser)
            
            return prettyString
        }
    }
    
    public var streetAddress: String {
        get {
            return addressLineOne + " " + addressLineTwo
        }
    }
    
    public var shareStringDescription: String {
        get {
            var returnString = NSLocalizedString("StationModelShareStationName", comment: "") + "\n" + stationName
            
            if streetAddress != "" {
                returnString += "\n\n" + NSLocalizedString("StationModelShareAddress", comment: "") + "\n" + streetAddress
            }
            
            return returnString
        }
    }
    
    @objc public var coordinate: CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude) }
    }
    
    public var title: String? {
        get { return self.stationName }
    }
    
    public var subtitle: String? {
        get { return NSLocalizedString("StationModelAnnotationBikes", comment: "") + ": \(availableBikes) " +  NSLocalizedString("StationModelAnnotationOpenDocks", comment: "") + ": \(availableDocks)" }
    }
    
    override init() {
    }
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        stationName <- map["stationName"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        availableBikes <- map["availableBikes"]
        availableDocks <- map["availableDocks"]
        addressLineOne <- map["stAddress1"]
        addressLineTwo <- map["stAddress2"]
        
    }
    
    public func setDistanceFromUser(usersLatitude: Double, usersLongitude: Double) {
        let usersLocation = CLLocation(latitude: usersLatitude, longitude: usersLongitude)
        let stationLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        self.distanceFromUser = usersLocation.distance(from: stationLocation)
    }
}
