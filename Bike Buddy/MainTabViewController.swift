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

    //MARK: - View Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NSNotification.Name(Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabViewController.refreshStationsData), name: NSNotification.Name(Constants.NotificationCenterEvent.StationsDataIsStale), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.StationsDataIsStale), object: nil)
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
                let storyboard: UIStoryboard = UIStoryboard(name: Constants.ViewNames.FirstTimeUseStoryboard, bundle: nil)
                if let firstVC: UIViewController = storyboard.instantiateInitialViewController() {
                    firstVC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                    present(firstVC, animated: true, completion: nil)
                }
            } else {
                if UIApplication.isConnectedToNetwork() {
                    if Stations.sharedInstance.list.count == 0 {
                        refreshStationsData()
                    }
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("GeneralNoNetworkConnectionMessageTitle", comment: ""), message: NSLocalizedString("GeneralNoNetworkConnectionMessageContent", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
                    alert.addAction(alertAction)
                    present(alert, animated: true) { () -> Void in }
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

        StationsDataService.sharedInstance.getAllStationData(apiUrl: SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)) {
            responseObject, error in

            if responseObject.count == 0 {
                let alert = UIAlertController(title: NSLocalizedString("GeneralNoStationsMessageTitle", comment: ""), message: NSLocalizedString("GeneralNoStationsMessageContent", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                self.present(alert, animated: true) { () -> Void in }
            } else {
                Stations.sharedInstance.list = responseObject
            }
        }
    }
    
    //MARK: - UI Tests

    private func setupForUITests() {
        Stations.sharedInstance.list = StationsDataService.sharedInstance.loadStationDataFromFile(fileName: "Divvy_API_Response.json")

        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: "Chicago" as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: "Divvy" as AnyObject)
    }
}
