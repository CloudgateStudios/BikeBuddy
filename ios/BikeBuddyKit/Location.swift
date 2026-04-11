//
//  Location.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

/**
 Represents a Location from the CityBikes API. This is usually found under a Network object.
 
 :Implements: Codable - Allows easy mapping via Swift protocols. See init(from decoder) and encode(to encoder).
 */
public class Location: Codable {
    
     // MARK: - Variables
    
    public var city: String?
    public var country: String?
    public var latitude: Double?
    public var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case city
        case country
        case latitude
        case longitude
    }
    
     // MARK: - Initalizers
    
    required public init?() {
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        city = try values.decode(String.self, forKey: .city)
        country = try values.decode(String.self, forKey: .country)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
    }
    
     // MARK: - Public Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
