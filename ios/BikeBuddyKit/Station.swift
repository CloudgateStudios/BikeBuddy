//
//  Station.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

/**
 Represents a bike sharing station.

 An immutable value type decoded from the CityBikes API. `distanceFromUser` is a
 runtime-only field (not part of the API payload) populated by
 `Stations.getClosestStations` when the user's location is known.
 */
public struct Station: Codable, Identifiable, Sendable {

    // MARK: - Variables

    public var id: String = ""
    public var stationName: String = ""
    public var availableDocks: Int = -1
    public var latitude: Double = 0.0
    public var longitude: Double = 0.0
    public var availableBikes: Int = -1
    public var timestamp: String = ""
    public var extraInfo: StationExtra = StationExtra()

    /// Distance in metres from the user. Not decoded from the API; set by
    /// `Stations.getClosestStations` (0 when the user location is unknown).
    public var distanceFromUser: Double = 0.0

    public var approximateDistanceAwayFromUser: String {
        let formatter = MKDistanceFormatter()
        formatter.units = .default
        formatter.unitStyle = .full

        let prettyString = "~ " + formatter.string(fromDistance: self.distanceFromUser)

        return prettyString
    }

    public var streetAddress: String {
        return extraInfo.address ?? ""
    }

    public var shareStringDescription: String {
        var returnString = String(localized: "StationModelShareStationName", bundle: .bikeBuddyKit) + "\n" + stationName

        if streetAddress != "" {
            returnString += "\n\n" + String(localized: "StationModelShareAddress", bundle: .bikeBuddyKit) + "\n" + streetAddress
        }

        return returnString
    }

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    // MARK: - Initalizers

    public init() {
    }
}

// MARK: - Codable

extension Station {

    enum CodingKeys: String, CodingKey {
        case id
        case availableBikes = "free_bikes"
        case availableDocks = "empty_slots"
        case stationName = "name"
        case latitude
        case longitude
        case timestamp
        case extraInfo = "extra"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.availableBikes = try values.decodeIfPresent(Int.self, forKey: .availableBikes) ?? 0
        self.availableDocks = try values.decodeIfPresent(Int.self, forKey: .availableDocks) ?? -1
        self.stationName = try values.decodeIfPresent(String.self, forKey: .stationName) ?? ""
        self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
        self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
        self.timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp) ?? ""
        self.extraInfo = try values.decodeIfPresent(StationExtra.self, forKey: .extraInfo) ?? StationExtra()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(availableBikes, forKey: .availableBikes)
        try container.encode(availableDocks, forKey: .availableDocks)
        try container.encode(stationName, forKey: .stationName)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(extraInfo, forKey: .extraInfo)
    }
}
