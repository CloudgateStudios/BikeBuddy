//
//  MainTabViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/24/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
    }
    
    override func viewDidAppear(animated: Bool) {
#if SCREENSHOTS
        Stations.sharedInstance.list = StationsDataService.sharedInstance.loadStationDataFromFile("Divvy_API_Response.json")
#else
        if(!SettingsService.sharedInstance.getSettingAsBool(FIRST_TIME_USE_COMPLETED_SETTINGS_KEY)) {
            let storyboard: UIStoryboard = UIStoryboard(name: STORYBOARD_FIRST_TIME_USE_FILE_NAME, bundle: nil)
            if let firstVC: UIViewController = storyboard.instantiateInitialViewController() {
                firstVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                
                presentViewController(firstVC, animated: true, completion: nil)
            }
        } else {
            if(UIApplication.isConnectedToNetwork()) {
                StationsDataService.sharedInstance.getAllStationData(SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_API_URL_SETTINGS_KEY)) {
                    responseObject, error in
                    
                    Stations.sharedInstance.list = responseObject
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("GeneralNoNetworkConnectionMessageTitle", comment: ""), message: NSLocalizedString("GeneralNoNetworkConnectionMessageContent", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                presentViewController(alert, animated: true) { () -> Void in }
            }
        }
#endif
    }
    
    private func setupStrings() {
        if let stationsTab = self.tabBar.items?[0] {
            stationsTab.title = NSLocalizedString("StationsListTabBarItemLabel", comment: "")
        }
        
        if let mapTab = self.tabBar.items?[1] {
            mapTab.title = NSLocalizedString("MapTabBarItemLabel", comment: "")
        }
        
        if let settingsTab = self.tabBar.items?[2] {
            settingsTab.title = NSLocalizedString("SettingsTabBarItemLabel", comment: "")
        }
    }
}
