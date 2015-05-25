//
//  StationsDataService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/21/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import Alamofire

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
    
    
    private init(){
    }
    
    /**
        Go get all the station data for the given API and return it as an array of Station objects
        
        :param: apiUrl The URL to the API to call. The API should return data in the format found in Supporting Files/Divvy_API_Response.json
        :param: completionHandler The closure to call when the response is received. Takes 2 parameters, responseObject as an Array of Station objects and an error as NSError
        
        :returns: void
    */
    func getAllStationData(apiUrl: String, completionHandler: (responseObject: [Station], error: NSError?) -> ()) {
        var returnStations = [Station]()
        
        Alamofire.request(.GET, apiUrl).response{ (_, _, data, error) in
            returnStations = self.parseStationDataToDictonary(data as! NSData)
            completionHandler(responseObject: returnStations, error: error)
        }
    }
    
    /**
        Load in Station data from a file. **Should only be used for development purposes**
    
        :param: fileName The name of the file to be loaded. Method makes the assumption that the file is part of the main bundle and is not in a subfolder.
    
        :returns: [Station]
    */
    func loadStationDataFromFile(fileName: String) -> [Station] {
        var jsonString:NSData = NSData()
        var fileNameParts:[String] = fileName.componentsSeparatedByString(".")
        
        if(fileNameParts.count == 2) {
            var path = NSBundle.mainBundle().pathForResource(fileNameParts[0] as String, ofType: fileNameParts[1] as String)
            var possibleContent = String(contentsOfFile: path!, encoding:NSUTF8StringEncoding, error: nil)
            var data = possibleContent!.dataUsingEncoding(NSUTF8StringEncoding)
            
            jsonString = data!
        }
        
        return parseStationDataToDictonary(jsonString)
    }
    
    private func parseStationDataToDictonary(data: NSData) -> [Station] {
        var stations = [Station]()
        var jsonError: NSError?
        
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String: AnyObject] {
            
            if let stationsBeanList = json["stationBeanList"] as? NSArray {
            
                for stationBean in stationsBeanList {
                    
                    var newStation = Station()
                    if let stationName = stationBean.valueForKey("stationName") as? String,
                           latitude = stationBean.valueForKey("latitude") as? Double,
                           longitude = stationBean.valueForKey("longitude") as? Double {
                        
                        newStation.stationName = stationName
                        newStation.latitude = latitude
                        newStation.longitude = longitude
                    
                        stations.append(newStation)
                    }
                    
                }
            }
        }
        
        return stations
    }
}