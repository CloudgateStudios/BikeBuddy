//
//  NetworksDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

@MainActor
public final class NetworksDataService {

    /**
     The shared instance that should be used to access all members of the service.
     */
    public static let sharedInstance = NetworksDataService()

    /**
     **Should not be used. Call NetworksDataService.sharedInstance instead.**
     */
    private init() {
    }
    
    /**
     Go get all the network data for the given API and return it as an array of Network objects

     - parameter apiUrl: The URL to the API to call. The API should return data in the format found in Supporting Files/CityBikes_Networks_API_Response.json

     - returns: An array of Network objects
     - throws: Network or decoding errors
     */
    public func getAllNetworkData(apiUrl: String) async throws -> [Network] {
        let data = try await CityBikesRequest.data(from: apiUrl)
        let model = try JSONDecoder().decode(CityBikesNetworksResponse.self, from: data)

        return model.networks ?? []
    }
}
