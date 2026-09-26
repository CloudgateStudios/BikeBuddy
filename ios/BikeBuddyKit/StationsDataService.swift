//
//  StationsDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/21/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

@MainActor
public final class StationsDataService {

    /**
     The shared instance that should be used to access all members of the service.
     */
    public static let sharedInstance = StationsDataService()

    /**
     **Should not be used. Call StationsDataService.sharedInstance instead.**
     */
    private init() {
    }
    
    /**
     Get all the station data for the given API and return it as an array of Station objects
     
     - parameter apiUrl: The URL to the API to call
     
     - returns: An array of Station objects
     - throws: Network or decoding errors
     */
    public func getAllStationData(apiUrl: String) async throws -> [Station] {
        let data = try await CityBikesRequest.data(from: apiUrl)
        let model = try JSONDecoder().decode(CityBikesNetworkDetailResponse.self, from: data)

        return model.network?.stations ?? []
    }
    
}
