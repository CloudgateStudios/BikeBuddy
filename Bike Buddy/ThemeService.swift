//
//  ThemeService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class ThemeService {
    //MARK: - Theme Variables
    
    private static let navigationBarBackgroundColor = UIColor.colorFromInteger(60, green: 163, blue: 220, alpha: 1.0)
    private static let tabBarTintColor = UIColor.colorFromInteger(60, green: 163, blue: 220, alpha: 1.0)
    private static let buttonBackgroundColor = UIColor.colorFromInteger(60, green: 163, blue: 220, alpha: 1.0)
    private static let fontName = "AppleSDGothicNeo-Regular"
    
    //MARK: - Class Functions
    
    /**
        Apply all the overall themes for the application. 
    
        **Should only be called once from the AppDelegate. If this needs to be called again your probably doing something wrong.**
    */
    class func applyTheme() {
        themeNavigationBar()
        themeTabBar()
        themeLabel()
    }
    
    /**
        Theme a button to give a consistent look and feel.
    
        Best place to use this is viewDidLoad in each ViewController that needs to theme a button.
    
        :param: button The UIButton that should be themed. It will be themed in place, not returned.
    */
    class func themeButton(button: UIButton) {
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        var defaultImage = UIImage.imageWithUIColor(buttonBackgroundColor)
        button.setBackgroundImage(defaultImage, forState: UIControlState.Normal)
        
        var highlightImage = UIImage.imageWithUIColor(buttonBackgroundColor)
        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
    }
    
    //MARK: - Private Functions
    
    /**
        Theme the navigation bar object for the whole app.
    */
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

    /**
        Theme the tab bar object for the whole app.
    */
    private static func themeTabBar() {
        let tabBarAppearance = UITabBar.appearance()

        tabBarAppearance.translucent = false
        tabBarAppearance.tintColor = tabBarTintColor
        
        let tabBarItemAppearance = UITabBarItem.appearance()
        
        tabBarItemAppearance.setTitleTextAttributes([NSFontAttributeName: UIFont(name: fontName, size: 10)!], forState: UIControlState.Normal)
    }
    
    /**
        Theme the labels for the whole app. This effects almost everything including labels inside of Map View annotations.
    */
    private static func themeLabel() {
        let labelApperance = UILabel.appearance()
        
        labelApperance.substituteFontName = fontName
    }
}