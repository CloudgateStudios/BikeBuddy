//
//  StationsListTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class StationsListTableViewController: UITableViewController {
    
    // MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStationsData", name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshStationsData", name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Stations.sharedInstance.list.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(STATIONS_LIST_TABLE_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! StationTableViewCell
        
        cell.stationNameLabel.text = Stations.sharedInstance.list[indexPath.row].stationName
        cell.numberOfBikesLabel.text = String(Stations.sharedInstance.list[indexPath.row].availableBikes)
        cell.numberOfAvailableDocksLabel.text = String(Stations.sharedInstance.list[indexPath.row].availableDocks)

        return cell
    }
    
    // MARK: - Stations Loading
    
    func setupUI() {
        self.tableView.reloadData()
    }
    
    func refreshStationsData() {
        StationsDataService.sharedInstance.getAllStationData(SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_API_URL_SETTINGS_KEY)) {
            responseObject, error in
            
            Stations.sharedInstance.list = responseObject
            self.tableView.reloadData()
        }
    }
}
