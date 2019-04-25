//
//  CityBikeNetworkDetailsResponse.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

/**
 Represents a response from the CityBikes API call for details about a network.
 
 :Implements: Codable - Allows easy mapping via Swift protocols. See init(from decoder) and encode(to encoder).
 */
public class CityBikesNetworkDetailResponse: Codable {
    
    // MARK: - Variables
    
    public var network: Network?
    
    enum CodingKeys: String, CodingKey {
        case network
    }
    
    // MARK: - Initalizers
    
    required public init?() {
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        network = try values.decode(Network.self, forKey: .network)
    }
    
    // MARK: - Public Functions
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(network, forKey: .network)
    }
}
