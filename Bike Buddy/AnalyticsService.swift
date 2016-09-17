//
//  AnalyticsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/23/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import Crashlytics

class AnalyticsService: AnalyticsServiceProtocol {

    /**
        The shared instanace that should be used to access all members of the service.
     */
    class var sharedInstance: AnalyticsService {
        struct Static {
            static let instance: AnalyticsService = AnalyticsService()
        }
        return Static.instance
    }

    /**
        Should not be used. Call AnalyticsService.sharedInstance instead.**
     */
    private init() {
    }

    /**
        Call to log an event that should be tracked.
     
        - parameter eventName: The name of the event that should be tracked. Must be provided.
        - parameter customAttributes: A dictonary of extra data that can be added to analytic events. This is optional.
    */
    func pegUserAction(eventName: String, customAttributes: [String: AnyObject] = ["": "" as AnyObject]) {
        Answers.logCustomEvent(withName: eventName, customAttributes: customAttributes)
    }
}
