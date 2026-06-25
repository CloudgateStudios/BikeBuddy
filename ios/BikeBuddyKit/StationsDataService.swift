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
     The shared instanace that should be used to access all members of the service.
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
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        guard let mime = httpResponse.mimeType, mime == "application/json" else {
            throw URLError(.cannotParseResponse)
        }
        
        let decoder = JSONDecoder()
        let model = try decoder.decode(CityBikesNetworkDetailResponse.self, from: data)
        
        return model.network?.stations ?? []
    }
    
}
