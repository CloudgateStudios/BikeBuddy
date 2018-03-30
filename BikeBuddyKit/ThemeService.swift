//
//  ThemeService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit

public class ThemeService {
    // MARK: - Theme Variables
    
    private static let navigationBarBackgroundColor = UIColor.colorFromInteger(red: 60, green: 163, blue: 220, alpha: 1.0)
    private static let tabBarTintColor = UIColor.colorFromInteger(red: 60, green: 163, blue: 220, alpha: 1.0)
    private static let buttonBackgroundColor = UIColor.colorFromInteger(red: 60, green: 163, blue: 220, alpha: 1.0)
    private static let textOnlyButtonTextColor = UIColor.colorFromInteger(red: 0, green: 122, blue: 255, alpha: 1.0)
    
    // MARK: - Class Functions
    
    /**
     Apply all the overall themes for the application.
     
     **Should only be called once from the AppDelegate. If this needs to be called again your probably doing something wrong.**
     */
    public class func applyTheme() {
        themeNavigationBar()
        themeTabBar()
    }
    
    /**
     Theme a button to give a consistent look and feel.
     
     Best place to use this is viewDidLoad in each ViewController that needs to theme a button.
     
     - parameter button: The UIButton that should be themed. It will be themed in place, not returned.
     */
    public class func themeButton(button: UIButton) {
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.backgroundColor = buttonBackgroundColor
        button.layer.cornerRadius = 4.0
    }
    
    /**
     Theme a text only button. Will not create a border around the button
     
     Best place to use this is viewDidLoad in each ViewController that needs to theme a button.
     
     - parameter textLabel: The UILabel that should be themed. It will be themed in place, not returned.
     */
    public class func themeTextOnlyButton(textLabel: UILabel) {
        textLabel.textColor = textOnlyButtonTextColor
    }
    
    // MARK: - Private Functions
    
    /**
     Theme the navigation bar object for the whole app.
     */
    private static func themeNavigationBar() {
        let navigationAppearance = UINavigationBar.appearance()
        
        navigationAppearance.barTintColor = navigationBarBackgroundColor
        navigationAppearance.tintColor = UIColor.white
        navigationAppearance.barStyle = UIBarStyle.black
        navigationAppearance.isTranslucent = false
    }
    
    /**
     Theme the tab bar object for the whole app.
     */
    private static func themeTabBar() {
        let tabBarAppearance = UITabBar.appearance()
        
        tabBarAppearance.isTranslucent = false
        tabBarAppearance.tintColor = tabBarTintColor
    }
}
