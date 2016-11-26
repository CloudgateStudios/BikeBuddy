//
//  StringsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 10/19/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class StringsService {

    /**
    Get a string for the given key. The string will be searched for inside the BikeBuddyKit framework.
     
     - parameter key: The key of the string that is needed
     
     - returns: String 
    */
    public class func getStringFor(key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle(identifier: Constants.BikeBuddyKit.BundleIdentifier)!, comment: "")
    }
}
