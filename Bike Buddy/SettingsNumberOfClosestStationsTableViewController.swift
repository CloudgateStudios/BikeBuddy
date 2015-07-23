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
    
    var options = [1,2,3,4,5]
    
    //MARK: - View Outlets
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarItem.title = NSLocalizedString("SettingsSelectNumOfClosestStationsNavBarTitle", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SETTINGS_NUMBER_OF_CLOSEST_STATIONS_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = String(options[indexPath.row])
        
        if(options[indexPath.row] == SettingsService.sharedInstance.getSettingAsInt(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        SettingsService.sharedInstance.saveSetting(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY, value: options[indexPath.row])
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: self)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
