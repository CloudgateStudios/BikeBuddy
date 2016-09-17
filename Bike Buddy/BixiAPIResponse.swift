//
//  BixiAPIResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 10/31/15.
//  Copyright © 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

class BixiAPIResponse: Mappable {
    var executionTime: String?
    var stationBeanList: [Station]?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        executionTime <- map["executionTime"]
        stationBeanList <- map["stationBeanList"]
    }
}
