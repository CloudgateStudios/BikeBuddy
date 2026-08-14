//
//  AnalyticsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

@MainActor
public final class AnalyticsService {

    /**
     The shared instanace that should be used to access all members of the service.
     */
    public static let sharedInstance = AnalyticsService()

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
    public func pegUserAction(eventName: String, customAttributes: [String: AnyObject] = ["": "" as AnyObject]) {
    }
}
