//
//  SettingsAboutViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/23/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class SettingsAboutViewController: UIViewController {

    //MARK: - View Outlets
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarItem.title = NSLocalizedString("SettingsAboutNavBarTitle", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
