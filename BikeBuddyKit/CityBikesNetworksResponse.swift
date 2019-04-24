//
//  CityBikesNetworksResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

/**
 Represents a response from the CityBikes API call for a list of available networks
 */
public class CityBikesNetworksResponse: Codable {
    
    // MARK: - Variables
    
    public var networks: [Network]?
    
    enum CodingKeys: String, CodingKey {
        case networks
    }
    
    // MARK: - Initalizers
    
    required public init?() {
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        networks = try values.decode([Network].self, forKey: .networks)
    }
    
    // MARK: - Public Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(networks, forKey: .networks)
    }
}
