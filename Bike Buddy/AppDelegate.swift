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

    // MARK: - Class Variables
    
    var window: UIWindow?
    
    // MARK: - Basic App Launch Handlers
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        var returnValue = true
        
        setupApplication()
        
        if let option = launchOptions {
            if option.keys.contains(UIApplicationLaunchOptionsKey.userActivityDictionary) {
                if let userActivityDict = option[UIApplicationLaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
                    if userActivityDict.keys.contains(UIApplicationLaunchOptionsKey.userActivityType) {
                        if let userActivity = userActivityDict["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity {
                            returnValue = handleActivity(userActivity: userActivity)
                        }
                    }
                }
            }
        }
        
        return returnValue
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.AppCameBackToForeground), object: self)
        
        if Stations.shouldBeUpdated() {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.StationDataIsStale)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsDataIsStale), object: self)
        }
    }
    
    // MARK: - User Activity Restore App Launch Handlers
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return handleActivity(userActivity: userActivity)
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        if userActivityType == Constants.UserActivity.StationActivityTypeIdentifier {
            return true
        }
        
        return false
    }
    
    // MARK: - Private Setup Functions
    
    private func setupApplication() {
        ThemeService.applyTheme()
        
        Fabric.with([Answers.self, Crashlytics.self])
    }
    
    private func handleActivity(userActivity: NSUserActivity) -> Bool {
        if userActivity.activityType == Constants.UserActivity.StationActivityTypeIdentifier {
            if self.window != nil {
                //As long as we have the window (which is the tab bar controller at root) send the restore call down to it to handle
                self.window?.rootViewController?.restoreUserActivityState(userActivity)
                
                return true
            }
        }
        
        return false
    }
}
