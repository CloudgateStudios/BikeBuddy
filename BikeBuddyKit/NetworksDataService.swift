//
//  NetworksDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

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
        
        Alamofire.request(apiUrl, method: .get, parameters: nil)
            .responseObject { (response: DataResponse<CityBikesNetworksResponse>) in
                if let testResponseResult = response.result.value?.networks {
                    returnNetworks = testResponseResult
                }
                
                completionHandler(returnNetworks, NSError(domain: Constants.NSErrorInfo.DomainString, code: Constants.NSErrorInfo.NetworkErrorCode))
        }
    }
}
