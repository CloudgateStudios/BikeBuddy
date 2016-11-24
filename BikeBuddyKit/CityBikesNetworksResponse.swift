//
//  CityBikesNetworksResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

public class CityBikesNetworksResponse: Mappable {
    public var networks: Array<Network>?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        networks <- map["networks"]
    }
}
