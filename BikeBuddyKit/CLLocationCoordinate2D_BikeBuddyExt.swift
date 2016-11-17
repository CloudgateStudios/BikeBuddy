//
//  CLLocationManager_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/16/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {

    /**
     Check to see if the location is actually a user location. If the user did not grant access to location then the coordinate that comes back is going to be 0.0 which will put them out in the middle of the ocean. Last time I checked that's not useful at all.
     */
    public func isCurrentUserLocationReal() -> Bool {
        if self.latitude == 0.0 {
            return false
        } else {
            return true
        }

    }
}
