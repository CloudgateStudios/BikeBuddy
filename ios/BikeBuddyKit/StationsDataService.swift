//
//  StationsDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/21/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

public class StationsDataService {
    
    /**
     The shared instanace that should be used to access all members of the service.
     */
    public class var sharedInstance: StationsDataService {
        struct Static {
            static let instance: StationsDataService = StationsDataService()
        }
        return Static.instance
    }
    
    /**
     **Should not be used. Call StationsDataService.sharedInstance instead.**
     */
    private init() {
    }
    
    /**
     Go get all the station data for the given API and return it as an array of Station objects
     
     - parameter apiUrl: The URL to the API to call. The API should return data in the format found in Supporting Files/Divvy_API_Response.json
     - parameter completionHandler: The closure to call when the response is received. Takes 2 parameters, responseObject as an Array of Station objects and an error as NSError
     
     - returns: No return. Just putting in a return placeholder so SwiftLint doesn't error out.  See https://github.com/realm/SwiftLint/issues/267 for more.
     */
    public func getAllStationData(apiUrl: String, completionHandler: @escaping (_ responseObject: [Station], _ error: NSError?) -> Void) {
        
        var returnStations = [Station]()
        
        let session = URLSession.shared
        if let url = URL(string: apiUrl) {
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                
                if error != nil || data == nil {
                    print("Client error!")
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    print("Server error!")
                    return
                }
                
                guard let mime = response.mimeType, mime == "application/json" else {
                    print("Wrong MIME type!")
                    return
                }
                
                do {
                    if let safeData = data {
                        let decoder = JSONDecoder()
                        
                        let model = try decoder.decode(CityBikesNetworkDetailResponse.self, from: safeData)
                        
                        if let testResponseResult = model.network?.stations {
                            returnStations = testResponseResult
                        }
                        
                        DispatchQueue.main.async {
                            completionHandler(returnStations, NSError(domain: Constants.NSErrorInfo.DomainString, code: Constants.NSErrorInfo.NetworkErrorCode))
                        }
                    }
                } catch let DecodingError.keyNotFound(key, context) {
                    print("JSON error: Key '\(key.stringValue)' not found:", context.debugDescription)
                    print("Coding path:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                } catch let DecodingError.typeMismatch(type, context) {
                    print("JSON error: Type '\(type)' mismatch:", context.debugDescription)
                    print("Coding path:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                } catch let DecodingError.valueNotFound(type, context) {
                    print("JSON error: Value of type '\(type)' not found:", context.debugDescription)
                    print("Coding path:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                } catch let DecodingError.dataCorrupted(context) {
                    print("JSON error: Data corrupted:", context.debugDescription)
                    print("Coding path:", context.codingPath.map { $0.stringValue }.joined(separator: " -> "))
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                    print("Full error: \(error)")
                }
            })
            
            task.resume()
        }
    }
    
    /**
     Modern async/await version: Get all station data for the given API and return it as an array of Station objects
     
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
