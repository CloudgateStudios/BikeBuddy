//
//  Stations.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/26/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

class Stations {
    class var sharedInstance: Stations {
        struct Static {
            static var instance: Stations?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Stations()
        }
        
        return Static.instance!
    }
    
    var list = [Station]() {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: self)
        }
    }
    
    private init() {
    }
}