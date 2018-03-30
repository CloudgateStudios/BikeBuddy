//
//  Network.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Represents a Network from the CityBikes API.
 
 :Implements: Mappable - Allows easy mapping from JSON to object via ObjectMapper
 */
public class Network: Mappable {
    public var company: [String]?
    public var gbfsHref: String?
    public var href: String?
    public var id: String?
    public var location: Location?
    public var name: String?
    public var stations: [Station]?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        company <- map["company"]
        gbfsHref <- map["gbfs_href"]
        href <- map["href"]
        id <- map["id"]
        location <- map["location"]
        name <- map["name"]
        stations <- map["stations"]
    }
}
