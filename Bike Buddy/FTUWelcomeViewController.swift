//
//  FTUWelcomeViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/7/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import BikeBuddyKit

class FTUWelcomeViewController: UIViewController {
    // MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var welcomeMessageLabel: UILabel!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTheme()
        setupStrings()
    }

    private func setupTheme() {
        ThemeService.themeButton(button: getStartedButton)
    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "GeneralAppName")
        welcomeMessageLabel.text = StringsService.getStringFor(key: "WelcomeMessageContent")
        getStartedButton.setTitle(StringsService.getStringFor(key: "WelcomeGetStartedButton"), for: .normal)
    }
}
