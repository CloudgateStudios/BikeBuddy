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
    static let navigationBarBackgroundColor = UIColor.colorFromInteger(60, green: 145, blue: 77, alpha: 1.0)
    static let tabBarTintColor = UIColor.colorFromInteger(60, green: 145, blue: 77, alpha: 1.0)
    static let buttonBackgroundColor = UIColor.colorFromInteger(60, green: 145, blue: 77, alpha: 1.0)
    
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
    
    class func themeButton(button: UIButton) {
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        var defaultImage = UIImage.imageWithUIColor(buttonBackgroundColor)
        button.setBackgroundImage(defaultImage, forState: UIControlState.Normal)
        
        var highlightImage = UIImage.imageWithUIColor(buttonBackgroundColor)
        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
    }

}