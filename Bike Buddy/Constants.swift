//
//  Constants.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

struct Constants {
    // MARK: - Settings Keys
    struct SettingsKey {
        static let FirstTimeUseCompleted = "IsFirstTimeUseCompleted"
        static let BikeServiceAPIURL = "BikeServiceApiUrl"
        static let BikeServiceCityName = "BikeServiceCityName"
        static let BikeServiceName = "BikeServiceName"
        static let NumberOfClosestStations = "NumberOfClosestStations"
    }
    
    // MARK: - Settings Defaults
    struct SettingsDefault {
        static let NumberOfClosestStations = 5
    }
    
    // MARK: - Storyboard/View Names
    struct ViewNames {
        static let FirstTimeUseStoryboard = "FirstTimeUse"
    }
    
    // MARK: - Segue Names
    struct SegueNames {
        static let GoToFirstTimeUseFinished = "GoToFTUFinished"
        static let ShowStationDetailFromMap = "ShowStationDetailFromMap"
        static let ShowStationDetailFromStationList = "ShowStationDetailFromStationsList"
    }
}


// MARK: - Table View Cell Resuse Identifiers
public let STATIONS_LIST_TABLE_CELL_REUSE_IDENTIFIER = "StationListCell"
public let SETTINGS_CITY_SELECT_TABLE_CELL_REUSE_IDENTIFIER = "SettingsCityCells"
public let FTU_CITY_SERVICE_CELL_REUSE_IDENTIFIER = "FTUCityServiceCell"
public let SETTINGS_NUMBER_OF_CLOSEST_STATIONS_CELL_REUSE_IDENTIFIER = "SettingsNumberOfClosestStationsCell"
public let SETTINGS_TELL_YOUR_FRIENDS_REUSE_IDENTIFIER = "TellYourFriends"
public let SETTINGS_RATE_APP_REUSE_IDENTIFIER = "RateBikeBuddy"
public let STATION_DETAIL_DIRECTIONS_TO_STATION_REUSE_IDENTIFIER = "StationDetailDirectionsToStation"
public let STATION_DETAIL_SHARE_STATION_REUSE_IDENTIFIER = "StationDetailShareStation"
public let ABOUT_OPEN_SOURCE_ALMOFIRE_REUSE_IDENTIFIER = "AboutOpenSourceAlamofire"
public let ABOUT_OPEN_SOURCE_OBJECTMAPPER_REUSE_IDENTIFIER = "AboutOpenSourceObjectMapper"
public let ABOUT_OPEN_SOURCE_AFOM_REUSE_IDENTIFIER = "AboutOpenSourceAFOM"
public let ABOUT_OPEN_SOURCE_SVPROGRESSHUD_REUSE_IDENTIFIER = "AboutOpenSourceSVProgressHUD"
public let ABOUT_LEGAL_PRIVACY_POLICY_REUSE_IDENTIFIER = "AboutLegalPrivacyPolicy"

// MARK: - Map View Reuse Identifiers
public let STATION_DETAIL_MAP_RESUE_IDENTIFIER = "StationDetailMapPinID"
public let FULL_MAP_VEIW_MAP_REUSE_IDENTIFIER = "FullMapPinID"

// MARK: - NSNotificationCenter Names
public let NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED = "FirstTimeUseCompleted"
public let NOTIFICATION_CENTER_NEW_CITY_SELECTED = "NewCitySelected"
public let NOTIFICATION_CENTER_STATIONS_LIST_UPDATED = "StationsListUpdated"
public let NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED = "NumberOfClosestStationsUpdated"
public let NOTIFICATION_CENTER_FAVORITE_STATIONS_LIST_UPDATED = "FavoriteStationsListUpdated"

// MARK: - Cities Plist
public let CITIES_PLIST_FILE_NAME = "Cities"
public let CITIES_PLIST_NAME_FIELD_KEY = "name"
public let CITIES_PLIST_SERVICE_NAME_FIELD_KEY = "serviceName"
public let CITIES_PLIST_API_URL_FIELD_KEY = "apiUrl"

// MARK: - Image Names
public let FAVORITE_NAV_BAR_ICON_NAME = "favoriteNavBarIcon"
public let NOT_FAVORITE_NAV_BAR_ICON_NAME = "notFavoriteNavBarIcon"

// MARK: - Sharing and Rating
public let APP_STORE_URL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=998776734&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"

// MARK: - Open Source Package URL's
public let OPEN_SOURCE_ALAMOFIRE_URL = "https://github.com/Alamofire/Alamofire"
public let OPEN_SOURCE_OBJECT_MAPPER_URL = "https://github.com/Hearst-DD/ObjectMapper"
public let OPEN_SOURCE_AFOM_URL = "https://github.com/tristanhimmelman/AlamofireObjectMapper"
public let OPEN_SOURCE_SVPROGRESSHUD_URL = "https://github.com/SVProgressHUD/SVProgressHUD"