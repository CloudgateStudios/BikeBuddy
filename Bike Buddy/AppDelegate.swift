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
}
