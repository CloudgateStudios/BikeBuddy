//
//  FTUWelcomeViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/7/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class FTUWelcomeViewController: UIViewController {
    // MARK: - View Outlets
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var welcomeMessageLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeService.themeButton(getStartedButton)
        
        navBarItem.title = NSLocalizedString("GeneralAppName", comment: "")
        welcomeMessageLabel.text = NSLocalizedString("WelcomeMessageContent", comment: "")
        getStartedButton.setTitle(NSLocalizedString("WelcomeGetStartedButton", comment: ""), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
