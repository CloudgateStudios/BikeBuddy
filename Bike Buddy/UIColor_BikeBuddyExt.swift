//
//  UIColor_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
        Helper function for creating a custom color. Instead of having to do the math of int/255.0 every time this function can take care of it for you.
    
        :param: red The value of red as an Int
        :param: green The value of green as an Int
        :param: blue The value of blue as an Int
        :param: alpha The alpha value of the color
    
        :returns: The new UIColor
    */
    class func colorFromInteger (red:Int, green:Int, blue:Int, alpha:Float) -> UIColor {
        let floatRed = CGFloat(red) / 255.0
        let floatGreen = CGFloat(green) / 255.0
        let floatBlue = CGFloat(blue) / 255.0
        return UIColor(red: floatRed, green: floatGreen, blue: floatBlue, alpha: CGFloat(alpha))
    }
}