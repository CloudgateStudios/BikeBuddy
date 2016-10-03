//
//  City.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class City {
    public var name: String = ""
    public var serviceName: String = ""
    public var apiUrl: String = ""
    
    public init() {
    }
    
    public func isValid() -> Bool {
        return name != "" && serviceName != "" && apiUrl != ""
    }
}
