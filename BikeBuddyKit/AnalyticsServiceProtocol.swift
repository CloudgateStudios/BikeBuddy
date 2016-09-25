//
//  AnalyticsServiceProtocol.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

protocol AnalyticsServiceProtocol {
    func pegUserAction(eventName: String, customAttributes: [String: AnyObject])
}
