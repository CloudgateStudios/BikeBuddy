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
        ThemeService.themeButton(getStartedButton)
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("FTUFinishedNavBarTitle", comment: "")
        getStartedButton.setTitle(NSLocalizedString("FTUFinishedButton", comment: ""), forState: .Normal)
    }

    //MARK: - User Interaction

    @IBAction func getStartedButtonClicked(sender: UIButton) {
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.FirstTimeUseCompleted, value: true)

        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationCenterEvent.FirstTimeUseCompleted, object: self)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
