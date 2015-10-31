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

class StationsDataService {
    
    /**
        The shared instanace that should be used to access all members of the service.
    */
    class var sharedInstance : StationsDataService {
        struct Static {
            static let instance : StationsDataService = StationsDataService()
        }
        return Static.instance
    }
    
    /**
        **Should not be used. Call StationsDataService.sharedInstance instead.**
    */
    private init(){
    }
    
    /**
        Go get all the station data for the given API and return it as an array of Station objects
        
        - parameter apiUrl: The URL to the API to call. The API should return data in the format found in Supporting Files/Divvy_API_Response.json
        - parameter completionHandler: The closure to call when the response is received. Takes 2 parameters, responseObject as an Array of Station objects and an error as NSError
    */
    func getAllStationData(apiUrl: String, completionHandler: (responseObject: [Station], error: NSError?) -> ()) {
        var returnStations = [Station]()
        
        Alamofire.request(.GET, apiUrl, parameters: nil)
            .responseObject { (response: BixiAPIResponse?, error: ErrorType?) in
                returnStations = (response?.stationBeanList)!
                
                completionHandler(responseObject: returnStations, error: error as? NSError)
        }
    }
    
    /**
        Load in Station data from a file. **Should only be used for development purposes**
    
        - parameter fileName: The name of the file to be loaded. Method makes the assumption that the file is part of the main bundle and is not in a subfolder.
    
        - returns: An array of Station objects
    */
    func loadStationDataFromFile(fileName: String) -> [Station] {
        var fileNameParts:[String] = fileName.componentsSeparatedByString(".")
        var returnData = [Station]()
        
        if(fileNameParts.count == 2) {
            let path = NSBundle.mainBundle().pathForResource(fileNameParts[0] as String, ofType: fileNameParts[1] as String)
            let possibleContent = try? String(contentsOfFile: path!, encoding:NSUTF8StringEncoding)
            
            if let data = possibleContent!.dataUsingEncoding(NSUTF8StringEncoding) {
                let responseObject = Mapper<BixiAPIResponse>().map(String(data: data, encoding: NSUTF8StringEncoding))
                returnData = (responseObject?.stationBeanList)!
            }

        }
    
        return returnData
    }
}