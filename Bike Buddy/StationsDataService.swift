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
        
        Alamofire.request(.GET, apiUrl).response{ (_, _, data, error) in
            do {
                try returnStations = self.parseStationDataToDictonary(data!)
            }
            catch { }
            completionHandler(responseObject: returnStations, error: error as? NSError)
        }
    }
    
    /**
        Load in Station data from a file. **Should only be used for development purposes**
    
        - parameter fileName: The name of the file to be loaded. Method makes the assumption that the file is part of the main bundle and is not in a subfolder.
    
        - returns: An array of Station objects
    */
    func loadStationDataFromFile(fileName: String) -> [Station] {
        var jsonString:NSData = NSData()
        var fileNameParts:[String] = fileName.componentsSeparatedByString(".")
        
        if(fileNameParts.count == 2) {
            let path = NSBundle.mainBundle().pathForResource(fileNameParts[0] as String, ofType: fileNameParts[1] as String)
            let possibleContent = try? String(contentsOfFile: path!, encoding:NSUTF8StringEncoding)
            let data = possibleContent!.dataUsingEncoding(NSUTF8StringEncoding)
            
            jsonString = data!
        }
        
        var returnData = [Station]()
        
        do  {
            try returnData = parseStationDataToDictonary(jsonString)
        }
        catch {
            
        }
        
        return returnData
    }
    
    /**
        Does the heavy lifting of converting raw JSON into a usable object.
    
        - parameter data: The raw JSON data as NSData
    
        - returns: An array of Station objects
    */
    private func parseStationDataToDictonary(data: NSData) throws -> [Station] {
        var stations = [Station]()
        //var jsonError: NSError?
        
        if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
            
            if let stationsBeanList = json["stationBeanList"] as? NSArray {
            
                for stationBean in stationsBeanList {
                    
                    let newStation = Station()
                    if let stationName = stationBean.valueForKey("stationName") as? String,
                           latitude = stationBean.valueForKey("latitude") as? Double,
                           longitude = stationBean.valueForKey("longitude") as? Double,
                           availableBikes = stationBean.valueForKey("availableBikes") as? Int,
                           availableDocks = stationBean.valueForKey("availableDocks") as? Int {
                        
                        newStation.stationName = stationName
                        newStation.latitude = latitude
                        newStation.longitude = longitude
                        newStation.availableBikes = availableBikes
                        newStation.availableDocks = availableDocks
                            
                            if let address1 = stationBean.valueForKey("stAddress1") as? String,
                                address2 = stationBean.valueForKey("stAddress2") as? String {
                                    newStation.streetAddress = address1 + " " + address2
                            }
                    
                        stations.append(newStation)
                    }
                    
                }
            }
        }
        
        return stations
    }
}