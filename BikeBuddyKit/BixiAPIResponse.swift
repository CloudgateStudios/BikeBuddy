//
//  BixiAPIResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

public class BixiAPIResponse: Mappable {
    public var executionTime: String?
    public var stationBeanList: [Station]?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        executionTime <- map["executionTime"]
        stationBeanList <- map["stationBeanList"]
    }
}
