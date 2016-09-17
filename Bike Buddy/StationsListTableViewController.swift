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

        NotificationCenter.default.addObserver(self, selector: #selector(StationsListTableViewController.updateClosestStations), name: NSNotification.Name(Constants.NotificationCenterEvent.StationsListUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StationsListTableViewController.updateClosestStations), name: NSNotification.Name(Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StationsListTableViewController.getUserLocation), name: NSNotification.Name(Constants.NotificationCenterEvent.AppCameBackToForeground), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.StationsListUpdated), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()

        disableEmptyCellsInTableView()

        getUserLocation()
    }
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("StationsListNavBarTitle", comment: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueNames.ShowStationDetailFromStationList {
            if let vc = (segue.destination as? StationDetailTableViewController) {
                vc.stationObject = self.tappedStation
            }
            self.tappedStation = nil
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.closestStations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.StationsList, for: indexPath as IndexPath) as? StationTableViewCell {
            
            cell.stationNameLabel.text = self.closestStations[indexPath.row].stationName
            cell.distanceLabel.text = self.closestStations[indexPath.row].approximateDistanceAwayFromUser + " " + NSLocalizedString("GeneralAwayLabel", comment: "")
            cell.numberOfBikesLabel.text = NumberFormatter.localizedString(from: self.closestStations[indexPath.row].availableBikes as NSNumber, number: .none)
            cell.numberOfDocksLabel.text = NumberFormatter.localizedString(from: self.closestStations[indexPath.row].availableDocks as NSNumber, number: .none)
            
            return cell
        } else {
            let newCell = UITableViewCell()
            return newCell
        }

    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.StationListHeader) as? StationListSectionHeaderCell {
            cell.headerLabel.text = NSLocalizedString("StationsListClosestStationsSectionHeader", comment: "")
            
            return cell.contentView
        } else {
            let newCell = UITableViewCell()
            
            return newCell
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LoadStationDetail, customAttributes: [Constants.AnalyticEventDetail.LoadedFrom: "Stations List" as AnyObject])
        
        self.tappedStation = self.closestStations[indexPath.row]
        
        self.performSegue(withIdentifier: Constants.SegueNames.ShowStationDetailFromStationList, sender: self)
    }

    private func disableEmptyCellsInTableView() {
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
        self.closestStations = Stations.getClosestStations(latitude: self.usersCurrentLocation.latitude, longitude: self.usersCurrentLocation.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations))
    }
}
