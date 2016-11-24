//
//  SettingsSelectCityTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/25/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

class SettingsSelectCityTableViewController: UITableViewController {
    //MARK: - Class Variables

    var networks = [Network]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    //MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsSelectCity)

        setupStrings()

        ProgressHUDService.sharedInstance.showHUD(statusMessage: StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
        
        NetworksDataService.sharedInstance.getAllStationData(apiUrl: "https://api.citybik.es/v2/networks") {
            responseObject, error in
            
            let temp = responseObject
            self.networks = temp.sorted { $0.name! < $1.name! }
            
            ProgressHUDService.sharedInstance.dismissHUD()
        }
    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "SettingsSelectCityNavBarTitle")
    }

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.SettingsCitySelect, for: indexPath as IndexPath)
        
        cell.textLabel?.text = networks[indexPath.row].name
        cell.detailTextLabel?.text = networks[indexPath.row].location?.city
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldCity = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceCityName)
        let analyticAttr = [Constants.AnalyticEventDetail.OldCity: oldCity, Constants.AnalyticEventDetail.NewCity: networks[indexPath.row].name]
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.SelectNewCity, customAttributes: analyticAttr as [String : AnyObject])
        
        let builtAPIURL = "https://api.citybik.es" + networks[indexPath.row].href!
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: networks[indexPath.row].location?.city as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: networks[indexPath.row].name as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: builtAPIURL as AnyObject)
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: self)
        
        _ = navigationController?.popViewController(animated: true)
    }
}
