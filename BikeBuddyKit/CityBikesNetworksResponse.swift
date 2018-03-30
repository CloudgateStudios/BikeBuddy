//
//  CityBikesNetworksResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Represents a response from the CityBikes API call for a list of available networks
 
 :Implements: Mappable - Allows easy mapping from JSON to object via ObjectMapper
 */
public class CityBikesNetworksResponse: Mappable {
    public var networks: [Network]?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        networks <- map["networks"]
    }
}
