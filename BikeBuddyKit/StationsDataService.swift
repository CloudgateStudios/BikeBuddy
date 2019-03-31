//
//  StationsDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/21/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

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
        
        AF.request(apiUrl, method: .get, parameters: nil)
            .responseObject { (response: DataResponse<CityBikesNetworkDetailResponse>) in
                if let testResponseResult = response.result.value?.network?.stations {
                    returnStations = testResponseResult
                }
                
                completionHandler(returnStations, NSError(domain: Constants.NSErrorInfo.DomainString, code: Constants.NSErrorInfo.NetworkErrorCode))
        }
    }
    
    /**
     Load in Station data from a file. **Should only be used for development purposes**
     
     - parameter fileName: The name of the file to be loaded. Method makes the assumption that the file is part of the main bundle and is not in a subfolder.
     
     - returns: An array of Station objects
     */
    //NEEDS TO BE RE-WRITTEN AFTER MOVING TO CITY BIKES API
    /*public func loadStationDataFromFile(fileName: String) -> [Station] {
        var fileNameParts: [String] = fileName.components(separatedBy: ".")
        var returnData = [Station]()
        
        if fileNameParts.count == 2 {
            //SOMETHING HERE SEEMS WRONG NOW THAT THIS IS IN A FRAMEWORK
            let path = Bundle.main.path(forResource: fileNameParts[0] as String, ofType: fileNameParts[1] as String)
            let possibleContent = try? String(contentsOfFile: path!, encoding:String.Encoding.utf8)
            
            if let data = possibleContent!.data(using: String.Encoding.utf8) {
                if let responseObject = Mapper<BixiAPIResponse>().map(JSONObject: data) {
                    returnData = (responseObject.stationBeanList)!
                }
            }
            
        }
        
        return returnData
    }*/
}
