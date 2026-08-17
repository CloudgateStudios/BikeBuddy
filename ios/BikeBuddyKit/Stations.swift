//
//  Stations.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import CoreLocation

@MainActor
public final class Stations {
    public static let sharedInstance = Stations()
    
    public var list = [Station]() {
        didSet {
            self.lastUpdated = NSDate()
        }
    }
    
    public private(set) var lastUpdated = NSDate()
    
    private init() {
    }
    
    public static func getClosestStations(latitude: Double, longitude: Double, numberOfStations: Int) -> [Station] {
        let stations = self.sharedInstance.list

        // Without a known user location, return the list as-is (capped) rather
        // than sorting by a meaningless zero distance.
        guard latitude != 0 || longitude != 0 else {
            return Array(stations.prefix(numberOfStations))
        }

        let usersLocation = CLLocation(latitude: latitude, longitude: longitude)

        let stationsWithDistance = stations.map { station -> Station in
            var stationCopy = station
            let stationLocation = CLLocation(latitude: station.latitude, longitude: station.longitude)
            stationCopy.distanceFromUser = usersLocation.distance(from: stationLocation)
            return stationCopy
        }

        let sorted = stationsWithDistance.sorted { $0.distanceFromUser < $1.distanceFromUser }

        return Array(sorted.prefix(numberOfStations))
    }
    
    public static func shouldBeUpdated() -> Bool {
        let elapsedTime = NSDate().timeIntervalSince(Stations.sharedInstance.lastUpdated as Date)
        
        if elapsedTime > Constants.Timers.RefreshStationsDataDifferenceInSeconds {
            return true
        } else {
            return false
        }
    }
}
