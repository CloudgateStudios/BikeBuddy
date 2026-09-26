//
//  CountryCleanupService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/24/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

@MainActor
public final class CountryCleanupService {

    /// Code to localized name, built once up front. The network picker's search looks
    /// a name up for every network on every keystroke, so this stays a dictionary
    /// lookup rather than a trip into the locale data each time.
    private let countryNames: [String: String]

    /**
     The shared instance that should be used to access all members of the service.
     */
    public static let sharedInstance = CountryCleanupService()

    /**
     **Should not be used. Call CountryCleanupService.sharedInstance instead.**
     */
    private init() {
        let locale = Locale.current
        var names = [String: String]()

        for code in NSLocale.isoCountryCodes {
            names[code] = locale.localizedString(forRegionCode: code)
        }

        countryNames = names
    }

    /**
     Takes a country short code and turns it into a full string of the countries name. This uses the built in platform API's so values returned will be localized to the locale of the devices settings.
     
     - parameter countryCode: The country code that needs to be turned into a string. Usually this is a two character string.
     
     - returns: A string of the full country name based on the locale settings of the device.
    */
    public func mapCountryCodeToString(countryCode: String) -> String {
        return countryNames[countryCode] ?? countryCode
    }
}
