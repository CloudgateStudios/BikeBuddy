//
//  StationActions.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import MapKit
import CoreLocation
import BikeBuddyKit

extension Station {

    /// Hands the station to Maps with walking directions.
    ///
    /// Shared rather than written at each call site: the map's selection card and the
    /// detail screen both offer this, and the launch options are the kind of detail
    /// that quietly diverges between two copies.
    @MainActor
    func openInMaps() {
        let mapItem = MKMapItem(
            location: CLLocation(latitude: latitude, longitude: longitude),
            address: nil
        )
        mapItem.name = stationName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}
