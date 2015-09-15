//
//  UIImage_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/5/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
        Create an image from a given color.
    
        - parameter color: The color that the image should be as a UIColor
    
        - returns: The image that was created
    */
    class func imageWithUIColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPointMake(0, 0), size: CGSizeMake(1, 1)))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}