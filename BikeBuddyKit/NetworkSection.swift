//
//  NetworkSection.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/26/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

struct NetworkSection {
    
    var title: String
    var items: [Network]
    
    init(title: String, objects: [Network]) {
        
        self.title = title
        self.items = objects
    }
}
