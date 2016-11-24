//
//  Stations.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class Stations {
    public static let sharedInstance = Stations()
    
    public var list = [Station]() {
        didSet {
            self.lastUpdated = NSDate()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: self)
        }
    }
    
    public private(set) var lastUpdated = NSDate()
    
    private init() {
    }
    
    public class func getClosestStations(latitude: Double, longitude: Double, numberOfStations: Int) -> [Station] {
        var stationsToReturn = [Station]()
        
        for station in self.sharedInstance.list {
            station.setDistanceFromUser(usersLatitude: latitude, usersLongitude: longitude)
        }
        
        var listCopy = self.sharedInstance.list
        
        if listCopy.count > 0 {
            listCopy.sort(by: { $0.distanceFromUser < $1.distanceFromUser })
            
            var upperLimit = SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations)
            if listCopy.count < upperLimit {
                upperLimit = listCopy.count
            }
            
            upperLimit = upperLimit - 1
            
            for index in 0...upperLimit {
                stationsToReturn.append(listCopy[index])
            }
        }
        
        return stationsToReturn
    }
    
    public class func shouldBeUpdated() -> Bool {
        let elapsedTime = NSDate().timeIntervalSince(Stations.sharedInstance.lastUpdated as Date)
        
        if elapsedTime > Constants.Timers.RefreshStationsDataDifferenceInSeconds {
            return true
        } else {
            return false
        }
    }
}
