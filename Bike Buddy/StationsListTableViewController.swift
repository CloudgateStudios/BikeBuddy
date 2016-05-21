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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsListTableViewController.updateClosestStations), name: Constants.NotificationCenterEvent.StationsListUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsListTableViewController.updateClosestStations), name: Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StationsListTableViewController.getUserLocation), name: Constants.NotificationCenterEvent.AppCameBackToForeground, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.NotificationCenterEvent.StationsListUpdated, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()

        disableEmptyCellsInTableView()

        getUserLocation()
    }
    
    @objc private func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("StationsListNavBarTitle", comment: "")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.SegueNames.ShowStationDetailFromStationList {
            if let vc = (segue.destinationViewController as? StationDetailTableViewController) {
                vc.stationObject = self.tappedStation
            }
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

        if let cell = tableView.dequeueReusableCellWithIdentifier("New" + Constants.TableViewCellResuseIdentifier.StationsList, forIndexPath: indexPath) as? NewStationTableViewCell {

            cell.stationNameLabel.text = self.closestStations[indexPath.row].stationName
            cell.distanceLabel.text = self.closestStations[indexPath.row].approximateDistanceAwayFromUser + " " + NSLocalizedString("GeneralAwayLabel", comment: "")
            cell.numberOfBikesLabel.text = NSNumberFormatter.localizedStringFromNumber(self.closestStations[indexPath.row].availableBikes, numberStyle: .NoStyle)
            cell.numberOfDocksLabel.text = NSNumberFormatter.localizedStringFromNumber(self.closestStations[indexPath.row].availableDocks, numberStyle: .NoStyle)

            return cell
        } else {
            let newCell = UITableViewCell()
            return newCell
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCellWithIdentifier("StationListSectionHeaderCell") as? StationListSectionHeaderCell {
            cell.headerLabel.text = NSLocalizedString("StationsListClosestStationsSectionHeader", comment: "")
            
            return cell.contentView
        } else {
            let newCell = UITableViewCell()
            
            return newCell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AnalyticsService.sharedInstance.pegUserAction(Constants.AnalyticEvent.LoadStationDetail, customAttributes: [Constants.AnalyticEventDetail.LoadedFrom: "Stations List"])
        
        self.tappedStation = self.closestStations[indexPath.row]

        self.performSegueWithIdentifier(Constants.SegueNames.ShowStationDetailFromStationList, sender: self)
    }

    private func disableEmptyCellsInTableView() {
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Location Manager

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Not sure about this change yet. It will make the view more up to date but I am concerned about battery life.
        //locationManager.stopUpdatingLocation()

        let locationArray = locations as NSArray
        if let locationObj = locationArray.lastObject as? CLLocation {
            self.usersCurrentLocation = locationObj.coordinate
            
            updateClosestStations()
        }
    }

    // MARK: - Stations Loading

    func updateClosestStations() {
        self.closestStations = Stations.getClosestStations(self.usersCurrentLocation.latitude, longitude: self.usersCurrentLocation.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(Constants.SettingsKey.NumberOfClosestStations))
    }
}
