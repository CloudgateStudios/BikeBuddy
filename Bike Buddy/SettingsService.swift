//
//  SettingsService.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

class SettingsService {
    var defaults: NSUserDefaults
    
    class var sharedInstance : SettingsService {
        struct Static {
            static let instance : SettingsService = SettingsService()
        }
        return Static.instance
    }
    
    private init() {
        defaults = NSUserDefaults.standardUserDefaults()
        setupDefaults()
    }
    
    private func setupDefaults() {
        if(self.getSettingAsInt(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY) == 0) {
            self.saveSetting(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY, value: NUMBER_OF_CLOSEST_STATIONS_SETTINGS_DEFAULT_VALUE)
        }
    }
    
    func clearAllSettings() {
        var appDomain: String = NSBundle.mainBundle().bundleIdentifier!
        defaults.removePersistentDomainForName(appDomain as String)
    }
    
    func saveSetting(key: String, value: AnyObject) {
        //Need to determine type of object
        switch value {
        case is Int:
            defaults.setInteger(value as! Int, forKey: key as String)
        case is Float:
            defaults.setFloat(value as! Float, forKey: key as String)
        case is Double:
            defaults.setDouble(value as! Double, forKey: key as String)
        case is Bool:
            defaults.setBool(value as! Bool, forKey: key as String)
        default:
            defaults.setObject(value, forKey: key as String)
            
        }
        
        defaults.synchronize()
    }
    
    func getSettingAsBool(key: String) -> Bool {
        return defaults.boolForKey(key)
    }
    
    func getSettingAsString(key: String) -> String {
        if let result = defaults.stringForKey(key) {
            return result
        }
        else {
            return ""
        }
    }
    
    func getSettingAsInt(key: String) -> Int {
        return defaults.integerForKey(key)
    }

}