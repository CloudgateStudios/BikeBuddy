//
//  NetworksDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class NetworksDataService {
    
    /**
     The shared instanace that should be used to access all members of the service.
     */
    public class var sharedInstance: NetworksDataService {
        struct Static {
            static let instance: NetworksDataService = NetworksDataService()
        }
        return Static.instance
    }
    
    /**
     **Should not be used. Call NetworksDataService.sharedInstance instead.**
     */
    private init() {
    }
    
    /**
     Go get all the network data for the given API and return it as an array of Network objects
     
     - parameter apiUrl: The URL to the API to call. The API should return data in the format found in Supporting Files/CityBikes_Networks_API_Response.json
     - parameter completionHandler: The closure to call when the response is received. Takes 2 parameters, responseObject as an Array of Network objects and an error as NSError
     */    
    public func getAllNetworkData(apiUrl: String, completionHandler: @escaping (_ responseObject: [Network], _ error: NSError?) -> Void) {
        var returnNetworks = [Network]()
        
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
                        let model = try decoder.decode(CityBikesNetworksResponse.self, from: safeData)
                        
                        if let testResponseResult = model.networks {
                            returnNetworks = testResponseResult
                        }
                        
                        DispatchQueue.main.async {
                            completionHandler(returnNetworks, NSError(domain: Constants.NSErrorInfo.DomainString, code: Constants.NSErrorInfo.NetworkErrorCode))
                        }
                    }
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                }
            })
            
            task.resume()
        }

    }
}
