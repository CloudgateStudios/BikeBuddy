//
//  FTUFinishedViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class FTUFinishedViewController: UIViewController {
    //MARK: _ View Outlets
    
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeService.themeButton(getStartedButton)
        
        navBarItem.title = NSLocalizedString("FTUFinishedNavBarTitle", comment: "")
        getStartedButton.titleLabel?.text = NSLocalizedString("FTUFinishedButton", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - User Interaction
    
    @IBAction func getStartedButtonClicked(sender: UIButton) {
        SettingsService.sharedInstance.saveSetting(FIRST_TIME_USE_COMPLETED_SETTINGS_KEY, value: true)
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: self)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
