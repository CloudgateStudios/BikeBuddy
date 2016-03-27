//
//  IAnalyticsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/26/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

protocol AnalyticsServiceProtocol {
    func pegUserAction(eventName: String, customAttributes: [String: AnyObject])
}
