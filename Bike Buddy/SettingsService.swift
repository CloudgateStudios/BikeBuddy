//
//  SettingsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation
import BikeBuddyKit

class SettingsService {
    var defaults: UserDefaults

    /**
        The shared instanace that should be used to access all members of the service.
    */
    class var sharedInstance: SettingsService {
        struct Static {
            static let instance: SettingsService = SettingsService()
        }
        return Static.instance
    }

    /**
        **Should not be used. Call StationsDataService.sharedInstance instead.**
    */
    private init() {
        defaults = UserDefaults.standard
        setupDefaults()
    }

    /**
        All default values should be set here. Most values can be added at runtime but any values that are needed during the first execution should be set here.
    */
    private func setupDefaults() {
        if self.getSettingAsInt(key: Constants.SettingsKey.NumberOfClosestStations) == 0 {
            self.saveSetting(key: Constants.SettingsKey.NumberOfClosestStations, value: Constants.SettingsDefault.NumberOfClosestStations as AnyObject)
        }
    }

    /**
        Will completely wipe out all settings. There's no going back after calling this.
    */
    func clearAllSettings() {
        let appDomain: String = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: appDomain as String)
        defaults.synchronize()
    }

    /**
        Quickly save a setting in the settings store.

        - parameter key: The key that should be used to save the setting.
        - parameter value: The value that should be stored. This can be any object and saveSetting will determine the best way to save it
    */
    func saveSetting(key: String, value: AnyObject) {
        //Need to determine type of object
        switch value {
        case is Int:
            if let intValue = value as? Int {
                defaults.set(intValue, forKey: key as String)
            }
        case is Float:
            if let floatValue = value as? Float {
                defaults.set(floatValue, forKey: key as String)
            }
        case is Double:
            if let doubleValue = value as? Double {
                defaults.set(doubleValue, forKey: key as String)
            }
        case is Bool:
            if let boolValue = value as? Bool {
                defaults.set(boolValue, forKey: key as String)
            }
        default:
            defaults.set(value, forKey: key as String)

        }

        defaults.synchronize()
    }

    /**
        Get a setting that was saved as a Bool value. Will return false if the there is no value for the key that is supplied

        - parameter key: The key of the value to be retrieved

        - returns: The value per the key given as a Bool
    */
    func getSettingAsBool(key: String) -> Bool {
        return defaults.bool(forKey: key)
    }

    /**
        Get a setting that was saved as a String value. Will return an empty string if the there is no value for the key that is supplied

        - parameter key: The key of the value to be retrieved

        - returns: The value per the key given as a String
    */
    func getSettingAsString(key: String) -> String {
        if let result = defaults.string(forKey: key) {
            return result
        } else {
            return ""
        }
    }

    /**
        Get a setting that was saved as an Int value. Will return 0 if the there is no value for the key that is supplied

        - parameter key: The key of the value to be retrieved

        - returns: The value per the key given as a Int
    */
    func getSettingAsInt(key: String) -> Int {
        return defaults.integer(forKey: key)
    }

}
