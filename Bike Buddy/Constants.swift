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

// MARK: - Storyboard/View Names
public let STORYBOARD_MAIN_FILE_NAME = "Main"
public let STORYBOARD_FIRST_TIME_USE_FILE_NAME = "FirstTimeUse"
public let LAUNCH_SCREEN_VIEW_FILE_NAME = "LaunchScreen"

// MARK: - Table View Cell Resuse Identifiers
public let STATIONS_LIST_TABLE_CELL_REUSE_IDENTIFIER = "StationListCell"
public let SETTINGS_CITY_SELECT_TABLE_CELL_REUSE_IDENTIFIER = "SettingsCityCells"

// MARK: - NSNotificationCenter Names
public let NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED = "FirstTimeUseCompleted"
public let NOTIFICATION_CENTER_NEW_CITY_SELECTED = "NewCitySelected"
public let NOTIFICATION_CENTER_STATIONS_LIST_UPDATED = "StationsListUpdated"