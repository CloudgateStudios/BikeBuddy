//
//  UIColor_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorFromInteger (red:Int, green:Int, blue:Int, alpha:Float) -> UIColor {
        let floatRed = CGFloat(red) / 255.0
        let floatGreen = CGFloat(green) / 255.0
        let floatBlue = CGFloat(blue) / 255.0
        return UIColor(red: floatRed, green: floatGreen, blue: floatBlue, alpha: CGFloat(alpha))
    }
}