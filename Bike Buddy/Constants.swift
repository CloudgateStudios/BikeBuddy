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

    // MARK: - Table View Cell Resuse Identifiers
    struct TableViewCellResuseIdentifier {
        static let StationsList = "StationListCell"
        static let SettingsCitySelect = "SettingsCitySelectCell"
        static let FirstTimeUseCity = "FTUCityServiceCell"
        static let SettingsNumberOfClosestStations = "SettingsNumberOfClosestStationsCell"
        static let SettingsTellYourFriends = "TellYourFriends"
        static let SettingsRateApp = "RateBikeBuddy"
        static let StationDetailDirectionsToStation = "StationDetailDirectionsToStation"
        static let StationDetailShareStation = "StationDetailShareStation"
        static let AboutThirdPartyAlmaofire = "AboutThirdPartyAlamofire"
        static let AboutThirdPartyObjectMapper = "AboutThirdPartyObjectMapper"
        static let AboutThirdPartyAFOM = "AboutThirdPartyAFOM"
        static let AboutThirdPartySVProgressHUD = "AboutThirdPartySVProgressHUD"
    }

    // MARK: - Map View Resuse Identifiers
    struct MapViewReuseIdentifier {
        static let StationDetail = "StationDetailMapPin"
        static let FullMap = "FullMapPin"
    }

    // MARK: - NSNotificationCenter Event Names
    struct NotificationCenterEvent {
        static let FirstTimeUseCompleted = "FirstTimeUseCompleted"
        static let NewCitySelected = "NewCitySelected"
        static let StationsListUpdated = "StationsListUpdated"
        static let NumberOfClosestStationsUpdated = "NumberOfClosestStationsUpdated"
    }

    // MARK: - Cities Plist
    struct CitiesPlist {
        static let FileName = "Cities"
        static let NameField = "name"
        static let ServiceNameField = "serviceName"
        static let APIURLField = "apiUrl"
    }

    // MARK: - External URL's
    struct ExtneralURL {
        static let AppStoreDeepLink = "https://itunes.apple.com/us/app/apple-store/id998776734?mt=8"
        static let Alamofire = "https://github.com/Alamofire/Alamofire"
        static let ObjectMapper = "https://github.com/Hearst-DD/ObjectMapper"
        static let AFOM = "https://github.com/tristanhimmelman/AlamofireObjectMapper"
        static let SVProgressHUD = "https://github.com/SVProgressHUD/SVProgressHUD"
    }
}
