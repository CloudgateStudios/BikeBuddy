//
//  Stations.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/26/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

class Stations {
    static let sharedInstance = Stations()

    var list = [Station]() {
        didSet {
            self.lastUpdated = NSDate()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: self)
        }
    }

    private(set) var lastUpdated = NSDate()

    private init() {
    }

    class func getClosestStations(latitude: Double, longitude: Double, numberOfStations: Int) -> [Station] {
        var stationsToReturn = [Station]()

        for station in self.sharedInstance.list {
            station.setDistanceFromUser(usersLatitude: latitude, usersLongitude: longitude)
        }

        var listCopy = self.sharedInstance.list

        if listCopy.count > 0 {
            listCopy.sort(by: { $0.distanceFromUser < $1.distanceFromUser })

            let upperLimit = SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations) - 1
            for index in 0...upperLimit {
                stationsToReturn.append(listCopy[index])
            }
        }

        return stationsToReturn
    }
    
    class func shouldBeUpdated() -> Bool {
        let elapsedTime = NSDate().timeIntervalSince(Stations.sharedInstance.lastUpdated as Date)
        
        if elapsedTime > Constants.Timers.RefreshStationsDataDifferenceInSeconds {
            return true
        } else {
            return false
        }
    }
}
