//
//  FTUFinishedViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

class FTUFinishedViewController: UIViewController {
    //MARK: - View Outlets

    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var navBarItem: UINavigationItem!

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTheme()
        setupStrings()
    }

    private func setupTheme() {
        ThemeService.themeButton(button: getStartedButton)
    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "FTUFinishedNavBarTitle")
        getStartedButton.setTitle(StringsService.getStringFor(key: "FTUFinishedButton"), for: .normal)
    }

    //MARK: - User Interaction
    @IBAction func getStartedButtonClicked(_ sender: UIButton) {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.FTUCompleted)
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.FirstTimeUseCompleted, value: true as AnyObject)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: self)
        
        self.dismiss(animated: true, completion: nil)
    }
}
