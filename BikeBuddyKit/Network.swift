//
//  Network.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

/**
 Represents a Network from the CityBikes API.
 */
public class Network: Codable {
    
    // MARK: - Variables
    
    public var company: [String]?
    public var gbfsHref: String?
    public var href: String?
    public var id: String?
    public var location: Location?
    public var name: String?
    public var stations: [Station]?
    
    enum CodingKeys: String, CodingKey {
        case company
        case gbfsHref = "gbfs_href"
        case href
        case id
        case location
        case name
        case stations
    }
    
    // MARK: - Initalizers
    
    required public init?() {
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.gbfsHref = try values.decodeIfPresent(String.self, forKey: .gbfsHref)
        self.href = try values.decodeIfPresent(String.self, forKey: .href)
        self.id = try values.decodeIfPresent(String.self, forKey: .id)
        self.location = try values.decodeIfPresent(Location.self, forKey: .location)
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
        self.stations = try values.decodeIfPresent([Station].self, forKey: .stations)
    }
    
    // MARK: - Public Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(company, forKey: .company)
        try container.encode(gbfsHref, forKey: .gbfsHref)
        try container.encode(href, forKey: .href)
        try container.encode(id, forKey: .id)
        try container.encode(location, forKey: .location)
        try container.encode(name, forKey: .name)
        try container.encode(stations, forKey: .stations)
    }
}
