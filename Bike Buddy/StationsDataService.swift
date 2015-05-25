//
//  StationsDataService.swift
//  Bike Buddy
//
//  Created by Arra Tom, US-L-4 on 5/21/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import Alamofire

class StationsDataService {
    
    class var sharedInstance : StationsDataService {
        struct Static {
            static let instance : StationsDataService = StationsDataService()
        }
        return Static.instance
    }
    
    private init(){
        
    }
    
    func getAllStationData(apiUrl: String) -> [Station] {
        Alamofire.request(.GET, apiUrl)
            .responseJSON { (_, _, JSON, _) in
                println(JSON)
                
                //self.parseStationDataToDictonary(JSON as! NSData)
        }
    }
    
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