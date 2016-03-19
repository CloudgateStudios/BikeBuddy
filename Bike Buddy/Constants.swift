//
//  Constants.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import Foundation

// MARK: - Settings Keys
public let FIRST_TIME_USE_COMPLETED_SETTINGS_KEY = "IsFirstTimeUseCompleted"
public let BIKE_SERVICE_API_URL_SETTINGS_KEY = "BikeServiceApiUrl"
public let BIKE_SERVICE_CITY_NAME_SETTINGS_KEY = "BikeServiceCityName"
public let BIKE_SERVICE_NAME_SETTINGS_KEY = "BikeServiceName"
public let NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY = "NumberOfClosestStations"

// MARK: - Settings Defaults
public let NUMBER_OF_CLOSEST_STATIONS_SETTINGS_DEFAULT_VALUE = 3

// MARK: - Archive Names
public let FAVORITE_STATIONS_ARCHIVE_NAME_ENDING = "favoriteStations.archive"

// MARK: - Storyboard/View Names
public let STORYBOARD_MAIN_FILE_NAME = "Main"
public let STORYBOARD_FIRST_TIME_USE_FILE_NAME = "FirstTimeUse"
public let LAUNCH_SCREEN_VIEW_FILE_NAME = "LaunchScreen"

// MARK: - Segue Names
public let GO_TO_FTU_SEGUE_IDENTIFIER = "GoToFTUFinished"
public let SHOW_STATION_DETAIL_FROM_MAP_SEGUE_IDENTIFIER = "showStationDetailFromMap"
public let SHOW_STATION_DETAIL_FROM_STATION_LIST_SEGUE_IDENTIFIER = "showStationDetailFromStationsList"

// MARK: - Table View Cell Resuse Identifiers
public let STATIONS_LIST_TABLE_CELL_REUSE_IDENTIFIER = "StationListCell"
public let SETTINGS_CITY_SELECT_TABLE_CELL_REUSE_IDENTIFIER = "SettingsCityCells"
public let FTU_CITY_SERVICE_CELL_REUSE_IDENTIFIER = "FTUCityServiceCell"
public let SETTINGS_NUMBER_OF_CLOSEST_STATIONS_CELL_REUSE_IDENTIFIER = "SettingsNumberOfClosestStationsCell"
public let STATION_DETAIL_DIRECTIONS_TO_STATION_REUSE_IDENTIFIER = "StationDetailDirectionsToStation"

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