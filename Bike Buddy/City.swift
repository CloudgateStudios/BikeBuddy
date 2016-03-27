//
//  City.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

class City {
    var name: String = ""
    var serviceName: String = ""
    var apiUrl: String = ""
    
    init() {
    }
    
    func isValid() -> Bool {
        return name != "" && serviceName != "" && apiUrl != ""
    }
}
