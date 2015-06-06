//
//  UIImage_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageWithUIColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPointMake(0, 0), size: CGSizeMake(1, 1)))
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}