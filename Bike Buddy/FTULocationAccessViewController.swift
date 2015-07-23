//
//  FTULocationAccessViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import CoreLocation

class FTULocationAccessViewController: UIViewController, CLLocationManagerDelegate {
    //MARK: - Class Variables
    
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()

    //MARK: - View Outlets
    
    @IBOutlet weak var giveLocationAccessButton: UIButton!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var mainMessageLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeService.themeButton(giveLocationAccessButton)
        
        navBarItem.title = NSLocalizedString("LocationAccessNavBarTitle", comment: "")
        mainMessageLabel.text = NSLocalizedString("LocationAccessMessageContent", comment: "")
        giveLocationAccessButton.setTitle(NSLocalizedString("LocationAccessButton", comment: ""), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - User Interaction
    
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

    //MARK: - Location Manager
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            goToNextView()
        }
        else {
            showNoLocationAccessMessage()
        }
    }
    
    //MARK: - View Specific Functions
    
    private func goToNextView() {
        self.performSegueWithIdentifier(GO_TO_FTU_SEGUE_IDENTIFIER, sender: self)
    }
    
    private func showNoLocationAccessMessage() {
        let alert = UIAlertController(title: NSLocalizedString("LocationAccessNotGrantedMessageTitle", comment: ""), message: NSLocalizedString("LocationAccessNotGrantedMessageContent", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true) { () -> Void in self.goToNextView() }

    }

}
