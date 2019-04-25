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

            setupNetworksBySection()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.NetworksListUpdated), object: self)
        }
    }
    
    public private(set) var indexListByNetwork = [String]()
    public private(set) var lastUpdated = NSDate()
    public private(set) var networksBySection = [(key: String, value: [Network])]()
    
    private init() {
    }
    
    private func setupNetworksBySection() {
        var bySectionWorkingCopy = [String: [Network]]()
        let sortedNetworkList = self.list.sorted { $0.name! < $1.name! }
        
        for item in sortedNetworkList {
            if let networkName = item.name {
                let firstLetter = String(networkName[networkName.startIndex]).uppercased()
                
                if bySectionWorkingCopy[firstLetter] != nil {
                    var currentItemsInSection = bySectionWorkingCopy[firstLetter]
                    currentItemsInSection?.append(item)
                    bySectionWorkingCopy[firstLetter] = currentItemsInSection
                } else {
                    bySectionWorkingCopy[firstLetter] = [item]
                }

            }
        }
        
        let workingcopy = bySectionWorkingCopy.sorted { $0.key < $1.key }
        self.networksBySection = workingcopy
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
    
    public class func getNetworksBySection() {
        
    }
}
