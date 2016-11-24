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
                    let alert = UIAlertController(title: StringsService.getStringFor(key: "GeneralNoNetworkConnectionMessageTitle"), message: StringsService.getStringFor(key: "GeneralNoNetworkConnectionMessageContent"), preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
                    alert.addAction(alertAction)
                    present(alert, animated: true) { () -> Void in }
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

    //MARK: - Stations List

    func refreshStationsData() {
        ProgressHUDService.sharedInstance.showHUD(statusMessage: StringsService.getStringFor(key: "MapLoadingPopupMessage"))

        StationsDataService.sharedInstance.getAllStationData(apiUrl: SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)) {
        //StationsDataService.sharedInstance.getAllStationData(apiUrl: "https://api.citybik.es/v2/networks/bubi") {
            responseObject, error in

            if responseObject.count == 0 {
                ProgressHUDService.sharedInstance.dismissHUD()
                
                let alert = UIAlertController(title: StringsService.getStringFor(key: "GeneralNoStationsMessageTitle"), message: StringsService.getStringFor(key: "GeneralNoStationsMessageContent"), preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                
                self.present(alert, animated: true) { () -> Void in }
            } else {
                Stations.sharedInstance.list = responseObject
            }
        }
    }
    
    //MARK: - UI Tests

    private func setupForUITests() {
        /*Stations.sharedInstance.list = StationsDataService.sharedInstance.loadStationDataFromFile(fileName: "Divvy_API_Response.json")

        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: "Chicago" as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: "Divvy" as AnyObject)*/
    }
}
