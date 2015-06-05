//
//  StationsListTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import CoreLocation

class StationsListTableViewController: UITableViewController, CLLocationManagerDelegate {
    // MARK: - Class Variables
    
    var locationManager = CLLocationManager()
    var closestStations = [Station]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.closestStations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(STATIONS_LIST_TABLE_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! StationTableViewCell
        
        cell.stationNameLabel.text = self.closestStations[indexPath.row].stationName

        return cell
    }
    
    // MARK: - Location Manager
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        var coord = locationObj.coordinate
        
        self.closestStations = Stations.getClosestStations(coord.latitude, longitude: coord.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY))
    }
    
    // MARK: - Stations Loading
    
    func setupUI() {
        println("SETUP TABLE UI")
        self.tableView.reloadData()
    }
}
