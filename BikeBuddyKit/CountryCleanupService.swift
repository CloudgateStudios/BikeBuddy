//
//  CountryCleanupService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/24/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public class CountryCleanupService {
    
    private var countryMappingDictonary = NSMutableDictionary()
    
    /**
     The shared instanace that should be used to access all members of the service.
     */
    public class var sharedInstance: CountryCleanupService {
        struct Static {
            static let instance: CountryCleanupService = CountryCleanupService()
        }
        return Static.instance
    }
    
    /**
     **Should not be used. Call CountryCleanupService.sharedInstance instead.**
     */
    private init() {
        let countryCodes = NSLocale.isoCountryCodes
        for code in countryCodes {
            let country = NSLocale(localeIdentifier: NSLocale.current.identifier).displayName(forKey: NSLocale.Key.countryCode, value: code)
            self.countryMappingDictonary.setValue(country, forKey: code)
        }

    }
    
    public func mapCountryCodeToString(countryCode: String) -> String {
        if let countryString = self.countryMappingDictonary.value(forKey: countryCode) {
            if let temp = countryString as? String {
                return temp
            }
        }
        
        return countryCode
    }
}
