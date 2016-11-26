//
//  CityBikeNetworkDetailsResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 Represents a response from the CityBikes API call for details about a network.
 
 :Implements: Mappable - Allows easy mapping from JSON to object via ObjectMapper
 */
public class CityBikesNetworkDetailResponse: Mappable {
    public var network: Network?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        network <- map["network"]
    }
}
