//
//  ThemeService.swift
//  Bike Buddy
//
//  Created by Arra Tom, US-L-4 on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import UIKit

class ThemeService {
    static let navigationBarBackgroundColor = UIColor(red: 22.0/255.0, green: 173.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    static let tabBarTintColor = UIColor(red: 22.0/255.0, green: 173.0/255.0, blue: 81.0/255.0, alpha: 1.0)
    
    class func themeNavigationBar() {
        let navigationAppearance = UINavigationBar.appearance()
        
        navigationAppearance.barTintColor = navigationBarBackgroundColor
        navigationAppearance.tintColor = UIColor.whiteColor()
        navigationAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        navigationAppearance.barStyle = UIBarStyle.Black
        navigationAppearance.translucent = false
    }
    
    class func themeTabBar() {
        let tabBarAppearance = UITabBar.appearance()

        tabBarAppearance.translucent = false
        tabBarAppearance.tintColor = tabBarTintColor
    }

}