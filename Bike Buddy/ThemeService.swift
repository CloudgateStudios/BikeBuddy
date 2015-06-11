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
    private static let navigationBarBackgroundColor = UIColor.colorFromInteger(60, green: 145, blue: 77, alpha: 1.0)
    private static let tabBarTintColor = UIColor.colorFromInteger(60, green: 145, blue: 77, alpha: 1.0)
    private static let buttonBackgroundColor = UIColor.colorFromInteger(60, green: 145, blue: 77, alpha: 1.0)
    private static let fontName = "AppleSDGothicNeo-Regular"
    
    class func applyTheme() {
        themeNavigationBar()
        themeTabBar()
        themeLabel()
    }
    
    private static func themeNavigationBar() {
        let navigationAppearance = UINavigationBar.appearance()
        
        navigationAppearance.barTintColor = navigationBarBackgroundColor
        navigationAppearance.tintColor = UIColor.whiteColor()
        navigationAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: fontName, size: 19)!]
        navigationAppearance.barStyle = UIBarStyle.Black
        navigationAppearance.translucent = false
        
        let barButtonItemApperance = UIBarButtonItem.appearance()
        
        barButtonItemApperance.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: fontName, size: 19)!], forState: UIControlState.Normal)
    }

    private static func themeTabBar() {
        let tabBarAppearance = UITabBar.appearance()

        tabBarAppearance.translucent = false
        tabBarAppearance.tintColor = tabBarTintColor
        
        let tabBarItemAppearance = UITabBarItem.appearance()
        
        tabBarItemAppearance.setTitleTextAttributes([NSFontAttributeName: UIFont(name: fontName, size: 10)!], forState: UIControlState.Normal)
    }
    
    private static func themeLabel() {
        let labelApperance = UILabel.appearance()
        
        labelApperance.substituteFontName = fontName
    }
    
    class func themeButton(button: UIButton) {
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        var defaultImage = UIImage.imageWithUIColor(buttonBackgroundColor)
        button.setBackgroundImage(defaultImage, forState: UIControlState.Normal)
        
        var highlightImage = UIImage.imageWithUIColor(buttonBackgroundColor)
        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
    }
}