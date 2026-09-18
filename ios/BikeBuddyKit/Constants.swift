//
//  Constants.swift
//  Bike Buddy
//
//  Created by Tom Arra on 9/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation

public struct Constants {
    // MARK: - Settings General
    public struct SettingsGeneral {
        public static let ShareGroupName = "group.com.cloudgatestudios.Bike-Buddy"
    }

    // MARK: - Settings Keys

    /// The keys the app owns, and the only ones SettingsService will read or write.
    ///
    /// CaseIterable rather than a hand written list: the app group migration needs to
    /// walk every key, and `allCases` is synthesized by the compiler, so adding a case
    /// below is all it takes for the migration to pick it up.
    public enum SettingsKey: String, CaseIterable {
        case settingsVersionNumber = "SettingsVersionNumber"
        case firstTimeUseCompleted = "IsFirstTimeUseCompleted"
        case bikeServiceAPIURL = "BikeServiceApiUrl"
        case bikeServiceCityName = "BikeServiceCityName"
        case bikeServiceName = "BikeServiceName"
        case numberOfClosestStations = "NumberOfClosestStations"
        case appearanceMode = "AppearanceMode"
    }

    // MARK: - Settings Defaults
    public struct SettingsDefault {
        public static let SettingsVersionNumber = 1
        public static let NumberOfClosestStations = 15
        public static let AppearanceMode = 0  // automatic
    }

    // MARK: - Timer Settings
    public struct Timers {
        public static let RefreshStationsDataDifferenceInSeconds = 300.0
    }

    public struct CityBikes {
        public static let BaseAPIURL = "https://api.citybik.es"
        public static let NetworksAPI = CityBikes.BaseAPIURL + "/v2/networks?fields=id,name,href,location"
    }

    // MARK: - External URL's
    public struct ExtneralURL {
        public static let AppStoreDeepLink = "https://itunes.apple.com/us/app/apple-store/id998776734?mt=8"
        public static let PrivacyPolicyURL = "https://cloudgatestudios.com/bikebuddy/privacy"
    }

    // MARK: - Custom NSError Definitions
    public struct NSErrorInfo {
        public static let DomainString = "BSBErrorDomain"
        public static let NetworkErrorCode = 60
    }

    public struct BikeBuddyKit {
        public static let BundleIdentifier = "com.cloudgatestudios.BikeBuddyKit"
    }

    public struct UserActivity {
        public static let StationActivityTypeIdentifier = "com.cloudgatestudios.Bike-Buddy.station"
    }
}
