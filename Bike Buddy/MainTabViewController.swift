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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
    }
    
    override func viewDidAppear(animated: Bool) {
        if(UIApplication.isUITest()) {
            setupForUITests()
        }
        else {
            
            if(!SettingsService.sharedInstance.getSettingAsBool(Constants.SettingsKey.FirstTimeUseCompleted)) {
                let storyboard: UIStoryboard = UIStoryboard(name: STORYBOARD_FIRST_TIME_USE_FILE_NAME, bundle: nil)
                if let firstVC: UIViewController = storyboard.instantiateInitialViewController() {
                    firstVC.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                    
                    presentViewController(firstVC, animated: true, completion: nil)
                }
            } else {
                if(UIApplication.isConnectedToNetwork()) {
                    if(Stations.sharedInstance.list.count == 0) {
                        refreshStationsData()
                    }
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("GeneralNoNetworkConnectionMessageTitle", comment: ""), message: NSLocalizedString("GeneralNoNetworkConnectionMessageContent", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
                    alert.addAction(alertAction)
                    presentViewController(alert, animated: true) { () -> Void in }
                }
            }
        }
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
    
    //MARK: - Stations List
    
    func refreshStationsData() {
        ProgressHUDService.sharedInstance.showHUD()
        
        StationsDataService.sharedInstance.getAllStationData(SettingsService.sharedInstance.getSettingAsString(Constants.SettingsKey.BikeServiceAPIURL)) {
            responseObject, error in
            
            Stations.sharedInstance.list = responseObject
        }
    }
    
    //MARK: - UI Tests
    
    private func setupForUITests() {
        Stations.sharedInstance.list = StationsDataService.sharedInstance.loadStationDataFromFile("Divvy_API_Response.json")
        
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_CITY_NAME_SETTINGS_KEY, value: "Chicago")
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_NAME_SETTINGS_KEY, value: "Divvy")
        SettingsService.sharedInstance.saveSetting(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY, value: 5)
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: self)
    }
}
