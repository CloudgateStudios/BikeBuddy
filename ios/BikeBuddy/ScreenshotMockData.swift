//
//  ScreenshotMockData.swift
//  Bike Buddy
//
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import Foundation
import CoreLocation
import BikeBuddyKit

/// Fixture data for the fastlane screenshot run, kept out of AppViewModel because it
/// is a wall of literals rather than logic.
///
/// These are **real Citi Bike stations at their real coordinates**, the 64 nearest to
/// the vantage point below. Only the availability counts are invented. Real geometry
/// matters for more than tidiness: the map tab clusters by grid cell, so a handful of
/// invented pins would show "2" bubbles where a real network the size of Citi Bike
/// shows hundreds - a screenshot that undersells the feature and misrepresents it at
/// the same time.
///
/// Not wrapped in `#if DEBUG`: fastlane snapshot builds Release.
enum ScreenshotMockData {

    /// Where the screenshot run stands — 8th Ave around W 42 St, with the nearest
    /// station a believable 250 feet off rather than underfoot.
    ///
    /// The simulator reports no fix and grants nothing under `fastlane snapshot`, so
    /// without a stand-in the listing would show the stations list in its "Not Sorted
    /// by Distance" state, with every distance label dropped and the stations in feed
    /// order. That is an honest picture of a denied permission, and the wrong thing to
    /// put on the App Store: it is not what the app does once it is allowed to work.
    static let coordinate = CLLocationCoordinate2D(latitude: 40.7570, longitude: -73.9905)

    /// Fixed so the "Updated at" label on the map agrees with the 9:41 in the status
    /// bar that `override_status_bar` paints. Two different times in one frame is the
    /// sort of detail that reads as sloppy even when nobody can say why.
    static var lastUpdated: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 18
        components.hour = 9
        components.minute = 41
        return Calendar.current.date(from: components) ?? Date()
    }

    private struct MockStation {
        let id: String
        let name: String
        let bikes: Int
        let docks: Int
        let latitude: Double
        let longitude: Double
    }

    /// The first eight are hand-set so the list exercises every row state — healthy,
    /// low (orange) and empty (red). The rest carry plausible counts and exist to give
    /// the map its density.
    private static let raw: [MockStation] = [
    MockStation(id: "m01", name: "W 42 St & 8 Ave", bikes: 12, docks: 19, latitude: 40.7576, longitude: -73.9910),
    MockStation(id: "m02", name: "W 41 St & 8 Ave", bikes: 7, docks: 26, latitude: 40.7564, longitude: -73.9900),
    MockStation(id: "m03", name: "W 39 St & 9 Ave", bikes: 2, docks: 31, latitude: 40.7565, longitude: -73.9937),
    MockStation(id: "m04", name: "8 Ave & W 38 St", bikes: 15, docks: 8, latitude: 40.7546, longitude: -73.9918),
    MockStation(id: "m05", name: "W 45 St & 8 Ave", bikes: 9, docks: 11, latitude: 40.7593, longitude: -73.9886),
    MockStation(id: "m06", name: "W 44 St & 9 Ave", bikes: 0, docks: 34, latitude: 40.7596, longitude: -73.9916),
    MockStation(id: "m07", name: "W 40 St & 7 Ave", bikes: 21, docks: 3, latitude: 40.7548, longitude: -73.9882),
    MockStation(id: "m08", name: "W 42 St & Dyer Ave", bikes: 5, docks: 17, latitude: 40.7590, longitude: -73.9938),
    MockStation(id: "m09", name: "Broadway & W 41 St", bikes: 21, docks: 10, latitude: 40.7551, longitude: -73.9866),
    MockStation(id: "m10", name: "W 36 St & 9 Ave", bikes: 5, docks: 18, latitude: 40.7546, longitude: -73.9952),
    MockStation(id: "m11", name: "W 43 St & 10 Ave", bikes: 18, docks: 13, latitude: 40.7601, longitude: -73.9946),
    MockStation(id: "m12", name: "W 47 St & 9 Ave", bikes: 17, docks: 18, latitude: 40.7615, longitude: -73.9901),
    MockStation(id: "m13", name: "W 35 St & 8 Ave", bikes: 0, docks: 31, latitude: 40.7528, longitude: -73.9928),
    MockStation(id: "m14", name: "Broadway & W 38 St", bikes: 21, docks: 2, latitude: 40.7530, longitude: -73.9873),
    MockStation(id: "m15", name: "W 36 St & 7 Ave", bikes: 14, docks: 5, latitude: 40.7521, longitude: -73.9895),
    MockStation(id: "m16", name: "W 42 St & 6 Ave", bikes: 4, docks: 19, latitude: 40.7549, longitude: -73.9845),
    MockStation(id: "m17", name: "W 35 St & 9 Ave", bikes: 20, docks: 19, latitude: 40.7541, longitude: -73.9961),
    MockStation(id: "m18", name: "W 37 St & Broadway", bikes: 8, docks: 15, latitude: 40.7523, longitude: -73.9877),
    MockStation(id: "m19", name: "Broadway & W 48 St", bikes: 39, docks: 0, latitude: 40.7602, longitude: -73.9849),
    MockStation(id: "m20", name: "8 Ave & W 49 St", bikes: 3, docks: 32, latitude: 40.7617, longitude: -73.9866),
    MockStation(id: "m21", name: "W 37 St & 10 Ave", bikes: 18, docks: 1, latitude: 40.7566, longitude: -73.9979),
    MockStation(id: "m22", name: "W 49 St & 8 Ave", bikes: 13, docks: 6, latitude: 40.7623, longitude: -73.9879),
    MockStation(id: "m23", name: "Broadway & W 37 St", bikes: 26, docks: 1, latitude: 40.7517, longitude: -73.9875),
    MockStation(id: "m24", name: "W 43 St & 6 Ave", bikes: 13, docks: 26, latitude: 40.7553, longitude: -73.9832),
    MockStation(id: "m25", name: "6 Ave & W 45 St", bikes: 11, docks: 8, latitude: 40.7570, longitude: -73.9826),
    MockStation(id: "m26", name: "8 Ave & W 33 St", bikes: 30, docks: 9, latitude: 40.7516, longitude: -73.9938),
    MockStation(id: "m27", name: "W 47 St & 10 Ave", bikes: 17, docks: 6, latitude: 40.7627, longitude: -73.9930),
    MockStation(id: "m28", name: "Broadway & W 36 St", bikes: 1, docks: 38, latitude: 40.7512, longitude: -73.9877),
    MockStation(id: "m29", name: "9 Ave & W 33 St", bikes: 3, docks: 16, latitude: 40.7526, longitude: -73.9968),
    MockStation(id: "m30", name: "W 47 St & 6 Ave", bikes: 22, docks: 1, latitude: 40.7582, longitude: -73.9820),
    MockStation(id: "m31", name: "W 50 St & 9 Ave", bikes: 1, docks: 22, latitude: 40.7636, longitude: -73.9892),
    MockStation(id: "m32", name: "10 Ave & W 34 St", bikes: 10, docks: 17, latitude: 40.7548, longitude: -73.9991),
    MockStation(id: "m33", name: "Hudson Blvd W & W 36 St", bikes: 19, docks: 4, latitude: 40.7568, longitude: -73.9997),
    MockStation(id: "m34", name: "W 44 St & 11 Ave", bikes: 19, docks: 0, latitude: 40.7620, longitude: -73.9970),
    MockStation(id: "m35", name: "11 Ave & W 41 St", bikes: 11, docks: 24, latitude: 40.7603, longitude: -73.9988),
    MockStation(id: "m36", name: "8 Ave & W 31 St", bikes: 3, docks: 28, latitude: 40.7506, longitude: -73.9947),
    MockStation(id: "m37", name: "W 33 St & 10 Ave", bikes: 12, docks: 15, latitude: 40.7538, longitude: -73.9994),
    MockStation(id: "m38", name: "6 Ave & W 34 St", bikes: 3, docks: 20, latitude: 40.7496, longitude: -73.9881),
    MockStation(id: "m39", name: "W 51 St & 7 Ave", bikes: 5, docks: 34, latitude: 40.7617, longitude: -73.9826),
    MockStation(id: "m40", name: "W 50 St & 10 Ave", bikes: 1, docks: 30, latitude: 40.7647, longitude: -73.9919),
    MockStation(id: "m41", name: "8 Ave & W 52 St", bikes: 31, docks: 8, latitude: 40.7637, longitude: -73.9852),
    MockStation(id: "m42", name: "W 34 St & Hudson Blvd E", bikes: 14, docks: 17, latitude: 40.7552, longitude: -74.0006),
    MockStation(id: "m43", name: "W 31 St & 7 Ave", bikes: 2, docks: 17, latitude: 40.7492, longitude: -73.9916),
    MockStation(id: "m44", name: "W 46 St & 11 Ave", bikes: 2, docks: 21, latitude: 40.7634, longitude: -73.9967),
    MockStation(id: "m45", name: "W 44 St & 5 Ave", bikes: 25, docks: 6, latitude: 40.7550, longitude: -73.9801),
    MockStation(id: "m46", name: "W 30 St & 8 Ave", bikes: 17, docks: 14, latitude: 40.7496, longitude: -73.9951),
    MockStation(id: "m47", name: "6 Ave & W 33 St", bikes: 1, docks: 34, latitude: 40.7490, longitude: -73.9885),
    MockStation(id: "m48", name: "E 40 St & 5 Ave", bikes: 14, docks: 5, latitude: 40.7521, longitude: -73.9816),
    MockStation(id: "m49", name: "W 51 St & 6 Ave", bikes: 5, docks: 22, latitude: 40.7607, longitude: -73.9804),
    MockStation(id: "m50", name: "W 48 St & Rockefeller Plaza", bikes: 2, docks: 21, latitude: 40.7578, longitude: -73.9793),
    MockStation(id: "m51", name: "W 37 St & 5 Ave", bikes: 2, docks: 37, latitude: 40.7504, longitude: -73.9834),
    MockStation(id: "m52", name: "Broadway & W 53 St", bikes: 6, docks: 33, latitude: 40.7634, longitude: -73.9827),
    MockStation(id: "m53", name: "W 34 St & 11 Ave", bikes: 8, docks: 31, latitude: 40.7559, longitude: -74.0021),
    MockStation(id: "m54", name: "W 29 St & 9 Ave", bikes: 5, docks: 26, latitude: 40.7501, longitude: -73.9984),
    MockStation(id: "m55", name: "W 52 St & 6 Ave", bikes: 33, docks: 2, latitude: 40.7613, longitude: -73.9798),
    MockStation(id: "m56", name: "W 54 St & 9 Ave", bikes: 6, docks: 25, latitude: 40.7660, longitude: -73.9874),
    MockStation(id: "m57", name: "E 43 St & Madison Ave", bikes: 7, docks: 16, latitude: 40.7535, longitude: -73.9790),
    MockStation(id: "m58", name: "E 48 St & 5 Ave", bikes: 23, docks: 8, latitude: 40.7572, longitude: -73.9781),
    MockStation(id: "m59", name: "W 53 St & 10 Ave", bikes: 29, docks: 10, latitude: 40.7667, longitude: -73.9906),
    MockStation(id: "m60", name: "W 51 St & Rockefeller Plaza", bikes: 26, docks: 13, latitude: 40.7597, longitude: -73.9781),
    MockStation(id: "m61", name: "E 46 St & Madison Ave", bikes: 5, docks: 26, latitude: 40.7554, longitude: -73.9776),
    MockStation(id: "m62", name: "W 30 St & 10 Ave", bikes: 17, docks: 22, latitude: 40.7527, longitude: -74.0024),
    MockStation(id: "m63", name: "8 Ave & W 55 St", bikes: 13, docks: 22, latitude: 40.7656, longitude: -73.9838),
    MockStation(id: "m64", name: "12 Ave & W 40 St", bikes: 15, docks: 24, latitude: 40.7609, longitude: -74.0028)
    ]

    static func stations() -> [Station] {
        raw.map { data in
            var station = Station()
            station.id = data.id
            station.stationName = data.name
            station.availableBikes = data.bikes
            station.availableDocks = data.docks
            station.latitude = data.latitude
            station.longitude = data.longitude
            return station
        }
    }
}
