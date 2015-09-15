//
//  Double_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

extension Double {
    
    /**
        Quick and easy formatting of a Double to a viewable String
    
        - parameter formatString: The way the number should be formatted. Example: ".2" will mean rounding to the first 2 decimal places
    
        - returns: The formatted String
    */
    func format(formatString: String) -> String {
        return NSString(format: "%\(formatString)f", self) as String
    }
}