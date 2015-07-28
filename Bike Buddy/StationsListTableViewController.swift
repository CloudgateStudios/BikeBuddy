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
    // MARK: - View Outlets
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    // MARK: - Class Variables
    
    var locationManager = CLLocationManager()
    var usersCurrentLocation = CLLocationCoordinate2D() {
        didSet {
            updateClosestStations()
        }
    }
    var closestStations = [Station]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var tappedStation: Station!
    
    // MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateClosestStations", name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateClosestStations", name: NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupStrings() {
        navBarItem.title = NSLocalizedString("StationsListNavBarTitle", comment: "")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SHOW_STATION_DETAIL_FROM_STATION_LIST_SEGUE_IDENTIFIER) {
            var vc = (segue.destinationViewController as! StationDetailViewController)
            vc.stationObject = self.tappedStation
            
            self.tappedStation = nil
        }

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
        cell.distanceLabel.text = self.closestStations[indexPath.row].approximateDistanceAwayFromUser
        cell.numberOfBikesLabel.text = String(self.closestStations[indexPath.row].availableBikes)

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return NSLocalizedString("StationsListClosestStationsSectionHeader", comment: "")
            default: return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tappedStation = self.closestStations[indexPath.row]
        
        self.performSegueWithIdentifier(SHOW_STATION_DETAIL_FROM_STATION_LIST_SEGUE_IDENTIFIER, sender: self)
    }
    
    // MARK: - Location Manager
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as! CLLocation
        self.usersCurrentLocation = locationObj.coordinate
    }
    
    // MARK: - Stations Loading
    
    func updateClosestStations() {
        self.closestStations = Stations.getClosestStations(self.usersCurrentLocation.latitude, longitude: self.usersCurrentLocation.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY))
    }
}
