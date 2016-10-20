//
//  StringsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 10/19/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class StringsService {

    public class func getStringFor(key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle(identifier: Constants.BikeBuddyKit.BundleIdentifier)!, comment: "")
    }
}
