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
            
            self.lastUpdated = NSDate()
        }
    }
    
    private(set) var lastUpdated = NSDate()
    
    private init() {
    }
    
    class func getClosestStations(latitude: Double, longitude: Double, numberOfStations: Int) -> [Station] {
        var stationsToReturn = [Station]()
        
        for station in self.sharedInstance.list {
            station.setDistanceFromUser(latitude, usersLongitude: longitude)
        }
        
        var listCopy = self.sharedInstance.list
        
        if listCopy.count > 0 {
            listCopy.sortInPlace({ $0.distanceFromUser < $1.distanceFromUser })
            
            for station in listCopy {
                stationsToReturn.append(station)
            }
        }
        
        return stationsToReturn
    }
}