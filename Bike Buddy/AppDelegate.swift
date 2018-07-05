//
//  AppDelegate.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import BikeBuddyKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        //SettingsService.sharedInstance
        //AnalyticsService.sharedInstance
        
        ThemeService.applyTheme()
        
        Fabric.with([Answers.self, Crashlytics.self])
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.AppCameBackToForeground), object: self)
        
        if Stations.shouldBeUpdated() {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.StationDataIsStale)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsDataIsStale), object: self)
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == Constants.UserActivity.StationActivityTypeIdentifier {
            if self.window != nil {
                //As long as we have the window (which is the tab bar controller at root) send the restore call down to it to handle
                self.window?.rootViewController?.restoreUserActivityState(userActivity)
            }
        }
        return true
    }
}
