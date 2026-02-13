//
//  UIColor+BikeBuddy.swift
//  Bike Buddy
//
//  Created by migration on 2/13/26.
//  Copyright © 2026 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
     Create a UIColor from integer RGB values (0-255) instead of floating point values
     
     - parameter red: Red component (0-255)
     - parameter green: Green component (0-255)
     - parameter blue: Blue component (0-255)
     - parameter alpha: Alpha component (0.0-1.0)
     
     - returns: UIColor with the specified color values
     */
    public class func colorFromInteger(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }
}
