//
//  MainTabViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 7/24/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var stationsTab = self.tabBar.items?[0] as! UITabBarItem
        stationsTab.title = NSLocalizedString("StationsListTabBarItemLabel", comment: "")
        
        var mapTab = self.tabBar.items?[1] as! UITabBarItem
        mapTab.title = NSLocalizedString("MapTabBarItemLabel", comment: "")
        
        var settingsTab = self.tabBar.items?[2] as! UITabBarItem
        settingsTab.title = NSLocalizedString("SettingsTabBarItemLabel", comment: "")
    }
}
