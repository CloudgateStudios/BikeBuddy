//
//  StationsListTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class StationsListTableViewController: UITableViewController {
    // MARK: - Class Variables
    
    var stations = [Station]()

    // MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStationsData", name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!SettingsService.sharedInstance.getSettingAsBool(FIRST_TIME_USE_COMPLETED_SETTINGS_KEY)) {
            let storyboard: UIStoryboard = UIStoryboard(name: STORYBOARD_FIRST_TIME_USE_FILE_NAME, bundle: nil)
            let firstVC: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
            
            self.presentViewController(firstVC, animated: true, completion: nil)
        }
        else {
            refreshStationsData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(STATIONS_LIST_TABLE_CELL_RESUE_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = stations[indexPath.row].stationName

        return cell
    }
    
    // MARK: - Stations Loading
    
    func refreshStationsData() {
        StationsDataService.sharedInstance.getAllStationData(SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_API_URL_SETTINGS_KEY)) {
            responseObject, error in
            
            self.stations = responseObject
            self.tableView.reloadData()
        }
    }
}
