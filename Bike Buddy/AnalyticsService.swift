//
//  AnalyticsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import Crashlytics

class AnalyticsService {
    // TODO: Track the user action that is important for you.
    //Answers.logContentViewWithName("Tweet", contentType: "Video", contentId: "1234", customAttributes: ["Favorites Count":20, "Screen Orientation":"Landscape"])
    
    /**
     The shared instanace that should be used to access all members of the service.
     */
    class var sharedInstance : AnalyticsService {
        struct Static {
            static let instance : AnalyticsService = AnalyticsService()
        }
        return Static.instance
    }
    
    /**
     **Should not be used. Call StationsDataService.sharedInstance instead.**
     */
    private init() {
    }

    func pegUserAction(action: String, contentType: String = "", contentId: String = "", customAttributes: [String: AnyObject] = ["": ""]) {
        Answers.logContentViewWithName(action, contentType: contentType, contentId: contentId, customAttributes: customAttributes)
    }
    
    func pegKeyMetric() {
        
    }

}