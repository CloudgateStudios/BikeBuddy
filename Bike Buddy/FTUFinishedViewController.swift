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

        setupTheme()
        setupStrings()
    }

    private func setupTheme() {
        ThemeService.themeButton(button: getStartedButton)
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("FTUFinishedNavBarTitle", comment: "")
        getStartedButton.setTitle(NSLocalizedString("FTUFinishedButton", comment: ""), for: .normal)
    }

    //MARK: - User Interaction

    @IBAction func getStartedButtonClicked(sender: UIButton) {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.FTUCompleted)
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.FirstTimeUseCompleted, value: true as AnyObject)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: self)

        self.dismiss(animated: true, completion: nil)
    }
}
