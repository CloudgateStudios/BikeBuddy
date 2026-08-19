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

        // Measure into a parallel array and sort indices against it. Copying every
        // Station just to carry a Double meant building a second copy of the whole
        // list, then discarding all but `numberOfStations` of it. Only the stations
        // actually returned are copied now.
        let distances = stations.map { station in
            usersLocation.distance(from: CLLocation(latitude: station.latitude, longitude: station.longitude))
        }

        let closestFirst = distances.indices.sorted { distances[$0] < distances[$1] }

        return closestFirst.prefix(numberOfStations).map { index in
            var station = stations[index]
            station.distanceFromUser = distances[index]
            return station
        }
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
