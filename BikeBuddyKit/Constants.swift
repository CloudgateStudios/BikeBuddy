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
    public struct SettingsKey {
        public static let SettingsVersionNumber = "SettingsVersionNumber"
        public static let FirstTimeUseCompleted = "IsFirstTimeUseCompleted"
        public static let BikeServiceAPIURL = "BikeServiceApiUrl"
        public static let BikeServiceCityName = "BikeServiceCityName"
        public static let BikeServiceName = "BikeServiceName"
        public static let NumberOfClosestStations = "NumberOfClosestStations"
    }
    
    // MARK: - Settings Defaults
    public struct SettingsDefault {
        public static let SettingsVersionNumber = 1
        public static let NumberOfClosestStations = 5
    }
    
    // MARK: - Timer Settings
    public struct Timers {
        public static let RefreshStationsDataDifferenceInSeconds = 300.0
    }
    
    // MARK: - Storyboard/View Names
    public struct ViewNames {
        public static let FirstTimeUseStoryboard = "FirstTimeUse"
    }
    
    // MARK: - Segue Names
    public struct SegueNames {
        public static let GoToFirstTimeUseNetworkSelect = "GoToFTUNetworkSelect"
        public static let GoToFirstTimeUseFinished = "GoToFTUFinished"
        public static let ShowStationDetailFromMap = "ShowStationDetailFromMap"
        public static let ShowStationDetailFromStationList = "ShowStationDetailFromStationsList"
    }
    
    // MARK: - Table View Cell Resuse Identifiers
    public struct TableViewCellResuseIdentifier {
        public static let StationsList = "StationListCell"
        public static let StationListHeader = "StationListSectionHeaderCell"
        public static let SettingsCitySelect = "SettingsCitySelectCell"
        public static let SettingsNetworkSelect = "SettingsNetworkSelectCell"
        public static let FTUNetworkSelect = "FTUNetworkSelectCell"
        public static let SettingsNumberOfClosestStations = "SettingsNumberOfClosestStationsCell"
        public static let SettingsTellYourFriends = "TellYourFriends"
        public static let SettingsRateApp = "RateBikeBuddy"
        public static let StationDetailDirectionsToStation = "StationDetailDirectionsToStation"
        public static let StationDetailShareStation = "StationDetailShareStation"
        public static let AboutThirdPartyAlmaofire = "AboutThirdPartyAlamofire"
        public static let AboutThirdPartyObjectMapper = "AboutThirdPartyObjectMapper"
        public static let AboutThirdPartyAFOM = "AboutThirdPartyAFOM"
        public static let AboutThirdPartySVProgressHUD = "AboutThirdPartySVProgressHUD"
        public static let AboutThridPartyFabric = "AboutThirdPartyFabric"
        public static let AboutThirdPartyDZN = "AboutThirdPartyDZN"
        public static let AboutPrivacyPolicy = "PrivacyPolicyCell"
    }
    
    // MARK: - Map View Resuse Identifiers
    public struct MapViewReuseIdentifier {
        public static let StationDetail = "StationDetailMapPin"
        public static let FullMap = "FullMapPin"
    }
    
    // MARK: - NSNotificationCenter Event Names
    public struct NotificationCenterEvent {
        public static let FirstTimeUseCompleted = "FirstTimeUseCompleted"
        public static let NewCitySelected = "NewCitySelected"
        public static let StationsListUpdated = "StationsListUpdated"
        public static let NumberOfClosestStationsUpdated = "NumberOfClosestStationsUpdated"
        public static let StationsDataIsStale = "StationDataIsStale"
        public static let AppCameBackToForeground = "AppCameBackToForeground"
        public static let NetworksListUpdated = "NetworksLIstUpdated"
    }
    
    // MARK: - Cities Plist
    public struct CitiesPlist {
        public static let FileName = "Cities"
        public static let NameField = "name"
        public static let ServiceNameField = "serviceName"
        public static let APIURLField = "apiUrl"
    }
    
    public struct CityBikes {
        public static let BaseAPIURL = "https://api.citybik.es"
        public static let NetworksAPI = CityBikes.BaseAPIURL + "/v2/networks"
    }
    
    // MARK: - Privacy Policy File
    public struct PrivacyPolicyFile {
        public static let FileName = "PrivacyPolicy"
        public static let FileExtension = "txt"
    }
    
    // MARK: - External URL's
    public struct ExtneralURL {
        public static let AppStoreDeepLink = "https://itunes.apple.com/us/app/apple-store/id998776734?mt=8"
        public static let Alamofire = "https://github.com/Alamofire/Alamofire"
        public static let ObjectMapper = "https://github.com/Hearst-DD/ObjectMapper"
        public static let AFOM = "https://github.com/tristanhimmelman/AlamofireObjectMapper"
        public static let SVProgressHUD = "https://github.com/SVProgressHUD/SVProgressHUD"
        public static let Fabric = "https://get.fabric.io"
        public static let DZNEmptyDataSet = "https://github.com/dzenbot/DZNEmptyDataSet"
    }
    
    // MARK: - Analytic Events
    public struct AnalyticEvent {
        public static let FTUCitySelected = "FTU City Selected"
        public static let LocationAccessGranted = "Location Access Granted"
        public static let LocationAccessDenied = "Location Access Denied"
        public static let FTUCompleted = "FTU Completed"
        public static let LoadStationDetail = "Load Station Detail"
        public static let GetDirectionsToStation = "Get Directions to Station"
        public static let ShareStation = "Share Station"
        public static let GoToAppStoreLink = "Go To App Store Link"
        public static let ShareAppWithFriends = "Share App with Friends"
        public static let OpenSettingsSelectCity = "Open Select City in Settings"
        public static let SelectNewCity = "Select New City"
        public static let OpenSettingsNumberOfClosestStations = "Open Number of Closest Stations in Settings"
        public static let SelectNewNumberOfClosestStations = "Select New Number of Closest Stations"
        public static let OpenSettingsAbout = "Open About in Settings"
        public static let OpenThirdPartySoftware = "Open Third Party Software"
        public static let OpenAboutPrivacyPolicy = "Open Privacy Policy in About"
        public static let StationDataIsStale = "Station Data is Stale"
    }
    
    // MARK: - Analytic Event Details
    public struct AnalyticEventDetail {
        public static let CitySelected = "City Selected"
        public static let LoadedFrom = "LoadedFrom"
        public static let OldCity = "Old City"
        public static let NewCity = "New City"
        public static let OldNumber = "Old Number"
        public static let NewNumber = "New Number"
        public static let ThirdPartySoftwareName = "Software Name"
    }
    
    // MARK: - Custom NSError Definitions
    public struct NSErrorInfo {
        public static let DomainString = "BSBErrorDomain"
        public static let NetworkErrorCode = 60
    }
    
    public struct BikeBuddyKit {
        public static let BundleIdentifier = "com.cloudgatestudios.BikeBuddyKit"
    }
}
