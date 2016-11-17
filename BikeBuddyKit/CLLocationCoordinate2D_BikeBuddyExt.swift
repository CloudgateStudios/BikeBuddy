//
//  CLLocationManager_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/16/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {

    public func isCurrentUserLocationReal() -> Bool {
        if self.latitude == 0.0 {
            return false
        } else {
            return true
        }

    }
}
