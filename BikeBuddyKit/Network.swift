//
//  Network.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper

public class Network: Mappable {
    public var company: Array<String>?
    public var gbfsHref: String?
    public var href: String?
    public var id: String?
    public var location: Location?
    public var name: String?
    public var stations: Array<Station>?
    
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
