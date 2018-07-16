//
//  MainTabViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/24/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

class MainTabViewController: UITabBarController {

    // MARK: - View Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NSNotification.Name(Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NSNotification.Name(Constants.NotificationCenterEvent.StationsDataIsStale), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.startFirstTimeUse), name: NSNotification.Name(Constants.NotificationCenterEvent.StartFirstTimeUse), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.StationsDataIsStale), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.StartFirstTimeUse), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
    }

    override func viewDidAppear(_ animated: Bool) {
        if UIApplication.isUITest() {
            setupForUITests()
        } else {
            if !SettingsService.sharedInstance.getSettingAsBool(key: Constants.SettingsKey.FirstTimeUseCompleted) {
                startFirstTimeUse()
            } else {
                if UIApplication.isConnectedToNetwork() {
                    if Stations.sharedInstance.list.count == 0 {
                        refreshStationsData()
                    }
                } else {
                    let alert = UIAlertController(title: StringsService.getStringFor(key: "GeneralNoNetworkConnectionMessageTitle"), message: StringsService.getStringFor(key: "GeneralNoNetworkConnectionMessageContent"), preferredStyle: UIAlertController.Style.alert)
                    let alertAction = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertAction.Style.default) { (_) -> Void in }
                    alert.addAction(alertAction)
                    present(alert, animated: true) { () -> Void in }
                }
            }
        }
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == Constants.UserActivity.StationActivityTypeIdentifier {
            //Make sure we move to the map tab first to get the stack right
            self.selectedViewController = self.viewControllers?[1]
            
            //Need to find the MapViewController and pass the restore call down to it. Being that it sits inside a navigation controller go get that first.
            if let navigationController = self.viewControllers![1] as? UINavigationController {                
                if let firstVC = navigationController.viewControllers[0] as? MapViewController {
                    firstVC.restoreUserActivityState(activity)
                }
            }
        }
    }

    private func setupStrings() {
        if let stationsTab = self.tabBar.items?[0] {
            stationsTab.title = StringsService.getStringFor(key: "StationsListTabBarItemLabel")
        }

        if let mapTab = self.tabBar.items?[1] {
            mapTab.title = StringsService.getStringFor(key: "MapTabBarItemLabel")
        }

        if let settingsTab = self.tabBar.items?[2] {
            settingsTab.title = StringsService.getStringFor(key: "SettingsTabBarItemLabel")
        }
    }
    
    @objc public func startFirstTimeUse() {
        let storyboard: UIStoryboard = UIStoryboard(name: Constants.ViewNames.FirstTimeUseStoryboard, bundle: nil)
        if let firstVC: UIViewController = storyboard.instantiateInitialViewController() {
            firstVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            
            present(firstVC, animated: true, completion: nil)
        }
    }

    // MARK: - Stations List

    @objc func refreshStationsData() {
        ProgressHUDService.sharedInstance.showHUD(statusMessage: StringsService.getStringFor(key: "MapLoadingPopupMessage"))

        StationsDataService.sharedInstance.getAllStationData(apiUrl: SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)) { responseObject, _ in

            if responseObject.count == 0 {
                ProgressHUDService.sharedInstance.dismissHUD()
                
                let alert = UIAlertController(title: StringsService.getStringFor(key: "GeneralNoStationsMessageTitle"), message: StringsService.getStringFor(key: "GeneralNoStationsMessageContent"), preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertAction.Style.default) { (_) -> Void in }
                alert.addAction(alertAction)
                
                self.present(alert, animated: true) { () -> Void in }
            } else {
                Stations.sharedInstance.list = responseObject
            }
        }
    }
    
    // MARK: - UI Tests

    private func setupForUITests() {
        /*Stations.sharedInstance.list = StationsDataService.sharedInstance.loadStationDataFromFile(fileName: "Divvy_API_Response.json")

        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: "Chicago" as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: "Divvy" as AnyObject)*/
    }
}
