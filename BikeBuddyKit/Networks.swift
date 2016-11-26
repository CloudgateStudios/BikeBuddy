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
            setupNetworkIndex()
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: self)
        }
    }
    
    public private(set) var indexListByNetwork = [String]()
    public private(set) var lastUpdated = NSDate()
    
    private init() {
    }
    
    private func setupNetworkIndex() {
        var networkIndexArray = [String]()
        
        for item in self.list {
            if let country = item.location?.country {
                let firstLetter = String(country[country.startIndex])
                
                if !networkIndexArray.contains(firstLetter) {
                    networkIndexArray.append(firstLetter)
                }
            }
        }
        
        self.indexListByNetwork = networkIndexArray.sorted()
    }
    
    public class func getSortedByNetworkName() -> [Network] {
        var nameSortedArray = [Network]()
            
        nameSortedArray = self.sharedInstance.list.sorted { $0.name! < $1.name! }
        
        return nameSortedArray
    }
    
    public class func searchThroughList(searchText: String) -> [Network] {
        var returnArray = [Network]()
        
        let lowercasedSearchText = searchText.lowercased()
        
        for item in self.sharedInstance.list {
            let lowercasedItem = item.name?.lowercased()
            
            if (lowercasedItem?.contains(lowercasedSearchText))! {
                returnArray.append(item)
            }
        }

        return returnArray.sorted { $0.name! < $1.name! }
    }
}
