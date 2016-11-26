//
//  SettingsSelectNetworkViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 11/24/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import Foundation
import BikeBuddyKit

class SettingsSelectNetworkViewController: UIViewController {
    //MARK: - Class Variables
    
    var networks = [Network]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.delegate = self
        
        //AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsSelectCity)
        
        setupStrings()
        
        ProgressHUDService.sharedInstance.showHUD(statusMessage: StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
        
        NetworksDataService.sharedInstance.getAllNetworkData(apiUrl: Constants.CityBikes.NetworksAPI) {
            responseObject, error in
            
            Networks.sharedInstance.list = responseObject
            self.networks = Networks.getSortedByNetworkName()
            
            ProgressHUDService.sharedInstance.dismissHUD()
        }
    
    }
    
    private func setupStrings() {
        navBarTitle.title = StringsService.getStringFor(key: "SettingsSelectNetworkNavBarTitle")
        searchBar.placeholder = StringsService.getStringFor(key: "SettingsSelectNetworkSearchBarPlaceholder")
    }
}

//MARK: - Table View

extension SettingsSelectNetworkViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.SettingsNetworkSelect, for: indexPath as IndexPath)
        
        cell.textLabel?.text = networks[indexPath.row].name
        cell.detailTextLabel?.text = (networks[indexPath.row].location?.city)! + ", " + CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: (networks[indexPath.row].location?.country)!)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldCity = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceCityName)
        let analyticAttr = [Constants.AnalyticEventDetail.OldCity: oldCity, Constants.AnalyticEventDetail.NewCity: networks[indexPath.row].name]
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.SelectNewCity, customAttributes: analyticAttr as [String : AnyObject])
        
        let builtAPIURL = Constants.CityBikes.BaseAPIURL + networks[indexPath.row].href!
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: networks[indexPath.row].location?.city as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: networks[indexPath.row].name as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: builtAPIURL as AnyObject)
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: self)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    /*func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Networks.sharedInstance.indexListByCountry
    }*/

}

//MARK: - Search Bar

extension SettingsSelectNetworkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.networks = Networks.searchThroughList(searchText: searchText)
        
        if searchText.characters.count == 0 {
            self.networks = Networks.getSortedByNetworkName()
        }
    }
}
