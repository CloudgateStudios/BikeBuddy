//
//  StationExtra.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

public class StationExtra: Mappable {
    public var address: String?
    public var lastUpdated: Double?
    public var renting: Int?
    public var returning: Int?
    public var uid: Int?
    
    required public convenience init?(map: Map) {
        self.init()
    }
    
    init() {
        
    }
    
    public func mapping(map: Map) {
        address <- map["address"]
        lastUpdated <- map["last_updated"]
        renting <- map["renting"]
        returning <- map["returning"]
        uid <- map["uid"]
    }
}
