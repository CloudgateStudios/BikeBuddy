//
//  UIApplication_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import SystemConfiguration

extension UIApplication {
    
    /**
        Gets the version of the application from the Info.plist file
    
        - returns: String representing the application version
    */
    class func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    /**
        Gets the build version of the application from the Info.plist file
    
        - returns: String representing the application build version
    */
    class func appBuild() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    /** 
        Gets the name of the application from the Info.plist file
     
        - returns: String representing the application name
    */
    class func appName() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleNameKey as (String)) as! String
    }

    /**
        Convience method to pretty up the version number for display purposes.
    
        - If the version number and build number are the same only one number will be returned
        - If the version number and build number are different the returned string will follow the format of "version (build)"
    
        - returns: The version number in a user displayable string
    */
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "\(version)" : "\(version) (\(build))"
    }
    
    /**
        Quickly check to see if the device has connectivity. 
    
        - returns: Bool True if there is connectivity, False if there is no connectivity
    */    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}