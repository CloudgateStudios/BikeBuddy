//
//  FTUSelectNetworkTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/28/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import BikeBuddyKit

class FTUSelectNetworkViewController: UIViewController {
    // MARK: - Class Variables
    
    var simpleNetworksList = [Network]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var sortedNetworksList = [(key: String, value: [Network])]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var isSearching: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!

    // MARK: - View Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsSelectNetworkViewController.reloadSortedNetworksDataIntoTable), name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.NetworksListUpdated), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.delegate = self
        
        setupStrings()
        
        ProgressHUDService.sharedInstance.showHUD(statusMessage: StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
        
        NetworksDataService.sharedInstance.getAllNetworkData(apiUrl: Constants.CityBikes.NetworksAPI) { responseObject, _ in
            
            Networks.sharedInstance.list = responseObject
            ProgressHUDService.sharedInstance.dismissHUD()
        }
        
    }
    
    private func setupStrings() {
        navBarTitle.title = StringsService.getStringFor(key: "SelectNetworkNavBarTitle")
        searchBar.placeholder = StringsService.getStringFor(key: "SelectNetworkSearchBarPlaceholder")
    }
    
    @objc public func reloadSortedNetworksDataIntoTable() {
        self.sortedNetworksList = Networks.sharedInstance.networksBySection
    }
}

// MARK: - Table View

extension FTUSelectNetworkViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isSearching {
            return 1
        } else {
            return self.sortedNetworksList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isSearching {
            return ""
        } else {
            return self.sortedNetworksList[section].key
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return simpleNetworksList.count
        } else {
            return self.sortedNetworksList[section].value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.FTUNetworkSelect, for: indexPath as IndexPath)
        
        if self.isSearching {
            cell.textLabel?.text = simpleNetworksList[indexPath.row].name
            cell.detailTextLabel?.text = (simpleNetworksList[indexPath.row].location?.city)! + ", " + CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: (simpleNetworksList[indexPath.row].location?.country)!)
        } else {
            cell.textLabel?.text = sortedNetworksList[indexPath.section].value[indexPath.row].name
            cell.detailTextLabel?.text = (sortedNetworksList[indexPath.section].value[indexPath.row].location?.city)! + ", " + CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: (sortedNetworksList[indexPath.section].value[indexPath.row].location?.country)!)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tappedNetwork: Network
        if self.isSearching {
            tappedNetwork = simpleNetworksList[indexPath.row]
        } else {
            tappedNetwork = sortedNetworksList[indexPath.section].value[indexPath.row]
        }
        
        let builtAPIURL = Constants.CityBikes.BaseAPIURL + tappedNetwork.href!
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: tappedNetwork.location?.city as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: tappedNetwork.name as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: builtAPIURL as AnyObject)
        
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.FTUCitySelected, customAttributes: [Constants.AnalyticEventDetail.CitySelected: tappedNetwork.name as AnyObject])

        self.performSegue(withIdentifier: Constants.SegueNames.GoToFirstTimeUseFinished, sender: self)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var returnArray = [String]()
        
        for item in self.sortedNetworksList {
            returnArray.append(item.key)
        }
        
        return returnArray
    }
    
}

// MARK: - Search Bar

extension FTUSelectNetworkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearching = true
        self.simpleNetworksList = Networks.searchThroughList(searchText: searchText)
        
        if searchText.count == 0 {
            self.isSearching = false
            self.reloadSortedNetworksDataIntoTable()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearching = false
    }
}
