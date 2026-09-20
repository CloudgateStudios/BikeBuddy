//
//  MapCameraFraming.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import MapKit
import CoreLocation

/// Where to point the map, given that on a phone something is usually sitting on top
/// of it.
///
/// Pure arithmetic, kept apart from MapView because none of it needs the view's state
/// and all of it is easier to follow on its own.
enum MapCameraFraming {

    /// Re-frames `region` so it fills the top `1 - covered` of the map instead of the
    /// whole of it: the span grows to make room, and the centre shifts to push the
    /// content up into the clear.
    static func region(
        _ region: MKCoordinateRegion,
        framedAbove covered: CGFloat
    ) -> MKCoordinateRegion {
        let visible = 1 - Double(covered)
        guard visible > 0 else { return region }

        let latitudeDelta = region.span.latitudeDelta / visible

        return MKCoordinateRegion(
            center: center(region.center, clearing: covered, latitudeDelta: latitudeDelta),
            span: MKCoordinateSpan(
                latitudeDelta: latitudeDelta,
                longitudeDelta: region.span.longitudeDelta
            )
        )
    }

    /// The centre a region needs so that `coordinate` lands in the middle of the strip
    /// the sheet leaves visible, rather than in the middle of the map behind it.
    static func center(
        _ coordinate: CLLocationCoordinate2D,
        clearing covered: CGFloat,
        latitudeDelta: Double
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: coordinate.latitude - Double(covered) * latitudeDelta / 2,
            longitude: coordinate.longitude
        )
    }

    /// The station-level span, or the current one when it is already tighter. Scales
    /// both axes together so the aspect the map is drawn at survives the change.
    static func selectionSpan(
        from current: MKCoordinateSpan?,
        target: Double = StationClusteringTuning.selectedStationSpan
    ) -> MKCoordinateSpan {
        guard let current, current.latitudeDelta > 0 else {
            return MKCoordinateSpan(latitudeDelta: target, longitudeDelta: target)
        }
        guard current.latitudeDelta > target else { return current }

        return MKCoordinateSpan(
            latitudeDelta: target,
            longitudeDelta: current.longitudeDelta * (target / current.latitudeDelta)
        )
    }
}
