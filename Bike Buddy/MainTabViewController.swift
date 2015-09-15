//
//  MainTabViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/24/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
    }
    
    private func setupStrings() {
        if let stationsTab = self.tabBar.items?[0] {
            stationsTab.title = NSLocalizedString("StationsListTabBarItemLabel", comment: "")
        }
        
        if let mapTab = self.tabBar.items?[1] {
            mapTab.title = NSLocalizedString("MapTabBarItemLabel", comment: "")
        }
        
        if let settingsTab = self.tabBar.items?[2] {
            settingsTab.title = NSLocalizedString("SettingsTabBarItemLabel", comment: "")
        }
    }
}
