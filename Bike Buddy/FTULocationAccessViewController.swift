//
//  FTULocationAccessViewController.swift
//  Bike Buddy
//
//  Created by Arra Tom, US-L-4 on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import CoreLocation

class FTULocationAccessViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func giveLocationAccessButtonClicked(sender: UIButton) {
        if(CLLocationManager.authorizationStatus() == .NotDetermined) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        else if(CLLocationManager.authorizationStatus() == .Restricted || CLLocationManager.authorizationStatus() == .Denied) {
            showNoLocationAccessMessage()
        }
        else {
            goToNextView()
        }
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            goToNextView()
        }
        else {
            showNoLocationAccessMessage()
        }
    }
    
    private func goToNextView() {
        self.performSegueWithIdentifier("GoToFTUFinished", sender: self)
    }
    
    private func showNoLocationAccessMessage() {
        let alert = UIAlertController(title: "Bike Buddy Needs Location Access", message: "Please give us location access so that we can find the closest bike stations to your location. Go to the Settings app to change this later on.", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true) { () -> Void in self.goToNextView() }

    }

}
