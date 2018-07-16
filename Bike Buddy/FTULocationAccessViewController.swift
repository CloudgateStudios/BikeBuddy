//
//  FTULocationAccessViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import CoreLocation
import BikeBuddyKit

class FTULocationAccessViewController: UIViewController, CLLocationManagerDelegate {
    // MARK: - Class Variables

    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    // MARK: - View Outlets

    @IBOutlet weak var giveLocationAccessButton: UIButton!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var mainMessageLabel: UILabel!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTheme()
        setupStrings()
    }

    private func setupTheme() {
        ThemeService.themeButton(button: giveLocationAccessButton)
    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "LocationAccessNavBarTitle")
        mainMessageLabel.text = StringsService.getStringFor(key: "LocationAccessMessageContent")
        giveLocationAccessButton.setTitle(StringsService.getStringFor(key: "LocationAccessButton"), for: .normal)
    }

    // MARK: - User Interaction

    @IBAction func userTappedGiveLocationAccessButton(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
            showNoLocationAccessMessage()
        } else {
            goToNextView()
        }
    }
    
    // MARK: - Location Manager
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LocationAccessGranted)
            
            goToNextView()
        } else {
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LocationAccessDenied)
            
            showNoLocationAccessMessage()
        }
    }

    // MARK: - View Specific Functions

    private func goToNextView() {
        self.performSegue(withIdentifier: Constants.SegueNames.GoToFirstTimeUseNetworkSelect, sender: self)
    }

    private func showNoLocationAccessMessage() {
        let alert = UIAlertController(title: StringsService.getStringFor(key: "LocationAccessNotGrantedMessageTitle"), message: StringsService.getStringFor(key: "LocationAccessNotGrantedMessageContent"), preferredStyle: UIAlertController.Style.alert)
        
        let alertAction = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertAction.Style.default) { (_) -> Void in
                self.goToNextView()
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true) { () -> Void in }
    }
}
