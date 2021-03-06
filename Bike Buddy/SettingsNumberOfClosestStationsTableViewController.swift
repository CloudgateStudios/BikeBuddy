//
//  SettingsNumberOfClosestStationsTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/4/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

class SettingsNumberOfClosestStationsTableViewController: UITableViewController {

    // MARK: - Class Variables

    var options = [5, 10, 15, 20]

    // MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsNumberOfClosestStations)

        setupStrings()
    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "SettingsSelectNumOfClosestStationsNavBarTitle")
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.SettingsNumberOfClosestStations, for: indexPath as IndexPath)
        
        cell.textLabel?.text = String(options[indexPath.row])
        
        if options[indexPath.row] == SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations) {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldValue = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.NumberOfClosestStations)
        let analyticAttr = [Constants.AnalyticEventDetail.OldNumber: oldValue, Constants.AnalyticEventDetail.NewNumber: options[indexPath.row].description]
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.SelectNewNumberOfClosestStations, customAttributes: analyticAttr as [String: AnyObject])
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.NumberOfClosestStations, value: options[indexPath.row] as AnyObject)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated), object: self)
        
        _ = self.navigationController?.popToRootViewController(animated: true)

    }
}
