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
        static let AboutThridPartyFabric = "AboutThirdPartyFabric"
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
        static let Fabric = "https://get.fabric.io"
    }
    
    // MARK: - Analytic Events
    struct AnalyticEvent {
        static let FTUCitySelected = "FTU City Selected"
        static let LocationAccessGranted = "Location Access Granted"
        static let LocationAccessDenied = "Location Access Denied"
        static let FTUCompleted = "FTU Completed"
        static let LoadStationDetail = "Load Station Detail"
        static let GetDirectionsToStation = "Get Directions to Station"
        static let ShareStation = "Share Station"
        static let GoToAppStoreLink = "Go To App Store Link"
        static let ShareAppWithFriends = "Share App with Friends"
        static let OpenSettingsSelectCity = "Open Select City in Settings"
        static let SelectNewCity = "Select New City"
        static let OpenSettingsNumberOfClosestStations = "Open Number of Closest Stations in Settings"
        static let SelectNewNumberOfClosestStations = "Select New Number of Closest Stations"
        static let OpenSettingsAbout = "Open About in Settings"
        static let OpenThirdPartySoftware = "Open Third Party Software"
        static let OpenAboutPrivacyPolicy = "Open Privacy Policy in About"
    }
    
    // MARK: - Analytic Event Details
    struct AnalyticEventDetail {
        static let CitySelected = "City Selected"
        static let LoadedFrom = "LoadedFrom"
        static let OldCity = "Old City"
        static let NewCity = "New City"
        static let OldNumber = "Old Number"
        static let NewNumber = "New Number"
        static let ThirdPartySoftwareName = "Software Name"
    }
}
