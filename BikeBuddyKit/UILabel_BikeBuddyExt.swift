//
//  UILabel_BikeBuddyExt.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit

extension UILabel {
    
    /**
     A shortcut on UILabel to set the font.
     */
    var substituteFontName: String {
        get { return self.font.fontName }
        set { self.font = UIFont(name: newValue, size: self.font.pointSize) }
    }
}
