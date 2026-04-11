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
    
    /**
     Takes a country short code and turns it into a full string of the countries name. This uses the built in platform API's so values returned will be localized to the locale of the devices settings.
     
     - parameter countryCode: The country code that needs to be turned into a string. Usually this is a two character string.
     
     - returns: A string of the full country name based on the locale settings of the device.
    */
    public func mapCountryCodeToString(countryCode: String) -> String {
        if let countryString = self.countryMappingDictonary.value(forKey: countryCode) {
            if let temp = countryString as? String {
                return temp
            }
        }
        
        return countryCode
    }
}
