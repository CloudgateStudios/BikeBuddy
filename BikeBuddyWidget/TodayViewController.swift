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
    
    var locationManager = CLLocationManager()
    var usersCurrentLocation = CLLocationCoordinate2D() {
        didSet {
            //self.updateClosestStations()
        }
    }
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bikesLabel: UILabel!
        
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
        
        print("URL: " + SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL))
        print("Number: " + SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.NumberOfClosestStations))
        
        StationsDataService.sharedInstance.getAllStationData(apiUrl: SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceAPIURL)) {
            responseObject, error in
            
            if responseObject.count == 0 {
                /*let alert = UIAlertController(title: NSLocalizedString("GeneralNoStationsMessageTitle", comment: ""), message: NSLocalizedString("GeneralNoStationsMessageContent", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                self.present(alert, animated: true) { () -> Void in }*/
                print("FAIL")
                completionHandler(NCUpdateResult.failed)
            } else {
                Stations.sharedInstance.list = responseObject
                
                if self.usersCurrentLocation.latitude != 0.0 {
                    var closestStations = Stations.getClosestStations(latitude: self.usersCurrentLocation.latitude, longitude: self.usersCurrentLocation.longitude, numberOfStations: SettingsService.sharedInstance.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations))
                    
                    print("NAME: " + closestStations[0].stationName)
                    
                    self.stationNameLabel.text = closestStations[0].stationName
                    self.distanceLabel.text = closestStations[0].approximateDistanceAwayFromUser
                    self.bikesLabel.text = NumberFormatter.localizedString(from: closestStations[0].availableBikes as NSNumber, number: .none)
                    completionHandler(NCUpdateResult.newData)
                    print("success")
                } else {
                    completionHandler(NCUpdateResult.failed)
                }
                
                
            }
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
