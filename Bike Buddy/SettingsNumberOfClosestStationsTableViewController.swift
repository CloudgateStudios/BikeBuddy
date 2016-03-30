//
//  SettingsNumberOfClosestStationsTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/4/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class SettingsNumberOfClosestStationsTableViewController: UITableViewController {

    //MARK: - Class Variables

    var options = [1, 2, 3, 4, 5]

    //MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsService.sharedInstance.pegUserAction(Constants.AnalyticEvent.OpenSettingsNumberOfClosestStations)

        setupStrings()
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SettingsSelectNumOfClosestStationsNavBarTitle", comment: "")
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCellResuseIdentifier.SettingsNumberOfClosestStations, forIndexPath: indexPath)

        cell.textLabel?.text = String(options[indexPath.row])

        if options[indexPath.row] == SettingsService.sharedInstance.getSettingAsInt(Constants.SettingsKey.NumberOfClosestStations) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let oldValue = SettingsService.sharedInstance.getSettingAsString(Constants.SettingsKey.NumberOfClosestStations)
        let analyticAttr = [Constants.AnalyticEventDetails.OldNumber: oldValue, Constants.AnalyticEventDetails.NewNumber: options[indexPath.row].description]
        AnalyticsService.sharedInstance.pegUserAction(Constants.AnalyticEvent.SelectNewNumberOfClosestStations, customAttributes: analyticAttr)
        
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.NumberOfClosestStations, value: options[indexPath.row])

        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated, object: self)

        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
