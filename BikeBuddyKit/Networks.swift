//
//  Networks.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/25/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class Networks {
    public static let sharedInstance = Networks()
    
    public var list = [Network]() {
        didSet {
            self.lastUpdated = NSDate()
            setupCountryIndex()
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: self)
        }
    }
    
    public private(set) var indexListByCountry = [String]()
    
    public private(set) var lastUpdated = NSDate()
    
    private init() {
    }

    private func setupCountryIndex() {
        var countryIndexArray = [String]()
        
        for item in self.list {
            if let country = item.location?.country {
                let firstLetter = String(country[country.startIndex])
            
                if !countryIndexArray.contains(firstLetter) {
                    countryIndexArray.append(firstLetter)
                }
            }
        }
        
        self.indexListByCountry = countryIndexArray.sorted()
    }
    
    public class func getSortedByName() -> [Network] {
        var nameSortedArray = [Network]()
            
        nameSortedArray = self.sharedInstance.list.sorted { $0.name! < $1.name! }
        
        return nameSortedArray
    }
}
