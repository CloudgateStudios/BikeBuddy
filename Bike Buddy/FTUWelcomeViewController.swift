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
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeService.themeButton(getStartedButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
