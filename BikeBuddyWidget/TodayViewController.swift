//
//  TodayViewController.swift
//  BikeBuddyWidget
//
//  Created by Tom Arra on 10/15/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
import BikeBuddyKit

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    // MARK: - Class Variables
    
    var locationManager = CLLocationManager()
    var usersCurrentLocation = CLLocationCoordinate2D()
    
    // MARK: - View Outlets
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bikesLabel: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = SettingsService.sharedInstance
        
        //self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
        startLoading()
        getUserLocation()
    }
    
    // MARK: - Widget Methods
    
    /*func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 220)
        }
    }*/
    
    func widgetPerformUpdate(completionHandler: @escaping ((NCUpdateResult) -> Void)) {
        let apiUrl = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)
        
        // If we have a URL then go get data
        if apiUrl != "" {
            StationsDataService.sharedInstance.getAllStationData(apiUrl: apiUrl) { responseObject, _ in
                
                if responseObject.count == 0 {
                    self.endLoading(completionHandler: completionHandler, result: .failed, errorString: StringsService.getStringFor(key: "TodayWidgetNoStationDataMessage"))
                } else {
                    Stations.sharedInstance.list = responseObject
                    
                    if self.usersCurrentLocation.latitude != 0.0 {
                        var closestStations = Stations.getClosestStations(latitude: self.usersCurrentLocation.latitude, longitude: self.usersCurrentLocation.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations))
                        
                        self.stationNameLabel.text = closestStations[0].stationName
                        self.distanceLabel.text = closestStations[0].approximateDistanceAwayFromUser + " " + StringsService.getStringFor(key: "GeneralAwayLabel")
                        self.bikesLabel.text = NumberFormatter.localizedString(from: closestStations[0].availableBikes as NSNumber, number: .none) + " " + StringsService.getStringFor(key: "TodayWidgetBikesAvailableLabel")

                        self.endLoading(completionHandler: completionHandler, result: .newData)
                    } else {
                        self.endLoading(completionHandler: completionHandler, result: .failed, errorString: StringsService.getStringFor(key: "TodayWidgetAllowLocationAccessMessage"))
                    }
                }
            }
        } else {
            //At this point seems like we dont have a URL which means user did not do first time use
            self.endLoading(completionHandler: completionHandler, result: .failed, errorString: StringsService.getStringFor(key: "TodayWidgetPleaseSetupAppMessage"))
        }
    }
    
    private func startLoading() {
        self.activitySpinner.startAnimating()
        self.activitySpinner.isHidden = false
        self.loadingLabel.isHidden = false
        
        self.stationNameLabel.isHidden = true
        self.distanceLabel.isHidden = true
        self.bikesLabel.isHidden = true
    }
    
    private func endLoading(completionHandler: @escaping ((NCUpdateResult) -> Void), result: NCUpdateResult, errorString: String = "") {
        self.activitySpinner.stopAnimating()
        self.activitySpinner.isHidden = true
        self.loadingLabel.isHidden = true
        
        switch result {
        case .newData:
            self.stationNameLabel.isHidden = false
            self.distanceLabel.isHidden = false
            self.bikesLabel.isHidden = false
        case .failed, .noData:
            self.errorLabel.text = errorString
            self.errorLabel.isHidden = false
        @unknown default:
            self.errorLabel.text = errorString
            self.errorLabel.isHidden = false
        }
        
        completionHandler(result)
    }
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        if let locationObj = locationArray.lastObject as? CLLocation {
            self.usersCurrentLocation = locationObj.coordinate
        }
    }
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}
