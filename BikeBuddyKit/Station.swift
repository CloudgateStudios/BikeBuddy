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

/**
 Represents a bike sharing station.
 
 :Implements: MKAnnotation - Allows Station objects to be passed to MapView's for quick annotation loading
 */
public class Station: NSObject, MKAnnotation, Codable {
    
    // MARK: - Variables
    
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
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case availableBikes = "free_bikes"
        case availableDocks = "empty_slots"
        case stationName = "name"
        case latitude = "latitude"
        case longitude = "longitude"
        case timestamp = "timestamp"
        case extraInto = "extra"
    }
    
    // MARK: - Initalizers
    
    override init() {
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.availableBikes = try values.decode(Int.self, forKey: .availableBikes)
        self.availableDocks = try values.decode(Int.self, forKey: .availableDocks)
        self.stationName = try values.decode(String.self, forKey: .stationName)
        self.latitude = try values.decode(Double.self, forKey: .latitude)
        self.longitude = try values.decode(Double.self, forKey: .longitude)
        self.timestamp = try values.decode(String.self, forKey: .timestamp)
        self.extraInfo = try values.decode(StationExtra.self, forKey: .extraInto)
    }
    
    // MARK: - Public Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(availableBikes, forKey: .availableBikes)
        try container.encode(availableDocks, forKey: .availableDocks)
        try container.encode(stationName, forKey: .stationName)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(extraInfo, forKey: .extraInto)
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
