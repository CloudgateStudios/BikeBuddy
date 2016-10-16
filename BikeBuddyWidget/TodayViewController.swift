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
import Crashlytics
import Fabric

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var usersCurrentLocation = CLLocationCoordinate2D() {
        didSet {
            //self.updateClosestStations()
        }
    }
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bikesLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        Fabric.with([Answers.self, Crashlytics.self])
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        _ = SettingsService.sharedInstance
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        
        getUserLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            self.preferredContentSize = maxSize
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 200)
        }
    }
    
    func widgetPerformUpdate(completionHandler: @escaping ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        let apiUrl = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)
        
        // If we have a URL then go get data
        if apiUrl != "" {
            StationsDataService.sharedInstance.getAllStationData(apiUrl: apiUrl) {
                responseObject, error in
                
                if responseObject.count == 0 {
                    completionHandler(NCUpdateResult.failed)
                } else {
                    Stations.sharedInstance.list = responseObject
                    
                    if self.usersCurrentLocation.latitude != 0.0 {
                        var closestStations = Stations.getClosestStations(latitude: self.usersCurrentLocation.latitude, longitude: self.usersCurrentLocation.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations))
                        
                        self.stationNameLabel.text = closestStations[0].stationName
                        self.distanceLabel.text = closestStations[0].approximateDistanceAwayFromUser
                        self.bikesLabel.text = NumberFormatter.localizedString(from: closestStations[0].availableBikes as NSNumber, number: .none)
                        completionHandler(NCUpdateResult.newData)
                    } else {
                        completionHandler(NCUpdateResult.failed)
                    }
                    
                    
                }
            }
        } else {
            //At this point seems like we dont have a URL which means user did not do first time use
        }
        
        

        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
    }
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Not sure about this change yet. It will make the view more up to date but I am concerned about battery life.
        //locationManager.stopUpdatingLocation()
        
        let locationArray = locations as NSArray
        if let locationObj = locationArray.lastObject as? CLLocation {
            self.usersCurrentLocation = locationObj.coordinate
            
            //updateClosestStations()
        }
    }

}
