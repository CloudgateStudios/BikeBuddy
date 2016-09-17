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
        if let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return versionString
        } else {
            return ""
        }
    }

    /**
        Gets the build version of the application from the Info.plist file

        - returns: String representing the application build version
    */
    class func appBuild() -> String {
        if let buildString = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            return buildString
        } else {
            return ""
        }
    }

    /**
        Gets the name of the application from the Info.plist file

        - returns: String representing the application name
    */
    class func appName() -> String {
        if let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as (String)) as? String {
            return appName
        } else {
            return ""
        }
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
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

    class func isUITest() -> Bool {
        let result = ProcessInfo.processInfo.environment.keys.contains("UITest")
        return result
    }
}
