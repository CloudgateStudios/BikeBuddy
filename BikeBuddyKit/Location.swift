//
//  Location.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

public class Location: Mappable {
    public var city: String?
    public var country: String?
    public var latitude: Double?
    public var longitude: Double?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        city <- map["city"]
        country <- map["country"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}
