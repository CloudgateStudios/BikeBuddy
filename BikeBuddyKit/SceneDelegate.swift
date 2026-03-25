//
//  SceneDelegate.swift
//  Bike Buddy
//
//  Created by migration on 2/13/26.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // The window is already set up from the storyboard, but we need to ensure it's configured
        if window == nil {
            window = UIWindow(windowScene: windowScene)
        }
        
        // Set the window for ProgressHUD to use
        ProgressHUD.presentationWindow = window
        
        // Handle any user activities from the connection options
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            configure(window: window, with: userActivity)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.AppCameBackToForeground), object: self)
        
        if Stations.shouldBeUpdated() {
            // AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.StationDataIsStale)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsDataIsStale), object: self)
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - State Restoration
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        configure(window: window, with: userActivity)
    }
    
    // MARK: - Private Helper Methods
    
    private func configure(window: UIWindow?, with activity: NSUserActivity) {
        if activity.activityType == Constants.UserActivity.StationActivityTypeIdentifier {
            // Pass the restoration call down to the root view controller to handle
            window?.rootViewController?.restoreUserActivityState(activity)
        }
    }
}
