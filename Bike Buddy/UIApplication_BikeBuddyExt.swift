//
//  UIApplication_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /**
        Gets the version of the application from the Info.plist file
    
        :returns: String representing the application version
    */
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    /**
        Gets the build version of the application from the Info.plist file
    
        :returns: String representing the application build version
    */
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }

    /**
        Convience method to pretty up the version number for display purposes.
    
        - If the version number and build number are the same only one number will be returned
        - If the version number and build number are different the returned string will follow the format of "version(build)"
    
        :returns: The version number in a user displayable string
    */
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "\(version)" : "\(version)(\(build))"
    }
}