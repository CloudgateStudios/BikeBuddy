//
//  StationExtra.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

/**
 Represents a extra data about a Station object. This conforms to the CityBikes API.

 :Implements: Codable - Allows easy mapping via Swift protocols. See init(from decoder) and encode(to encoder).
 */
public struct StationExtra: Codable, Sendable {

    // MARK: - Variables

    public var address: String?
    public var lastUpdated: String?
    public var renting: Int?
    public var returning: Int?
    public var uid: String?

    public init() {
    }
}

// MARK: - Codable

extension StationExtra {

    enum CodingKeys: String, CodingKey {
        case address
        case lastUpdated = "last_updated"
        case renting
        case returning
        case uid
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.address = try values.decodeIfPresent(String.self, forKey: .address)
        self.lastUpdated = try values.decodeIfPresent(String.self, forKey: .lastUpdated)

        // Handle renting - can be Int or Bool
        if let rentingInt = try? values.decodeIfPresent(Int.self, forKey: .renting) {
            self.renting = rentingInt
        } else if let rentingBool = try? values.decodeIfPresent(Bool.self, forKey: .renting) {
            self.renting = rentingBool ? 1 : 0
        }

        // Handle returning - can be Int or Bool
        if let returningInt = try? values.decodeIfPresent(Int.self, forKey: .returning) {
            self.returning = returningInt
        } else if let returningBool = try? values.decodeIfPresent(Bool.self, forKey: .returning) {
            self.returning = returningBool ? 1 : 0
        }

        self.uid = try values.decodeIfPresent(String.self, forKey: .uid)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(renting, forKey: .renting)
        try container.encode(returning, forKey: .returning)
        try container.encode(uid, forKey: .uid)
    }
}
