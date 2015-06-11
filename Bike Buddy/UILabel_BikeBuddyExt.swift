//
//  UIFont_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/10/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UILabel {
    
    var substituteFontName : String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
    }
    
}