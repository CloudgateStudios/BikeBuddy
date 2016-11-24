//
//  FTUSelectCityTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import Foundation
import BikeBuddyKit

class FTUSelectCityTableViewController: UITableViewController {
    //MARK: - Class Variables

    var networks = [Network]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    //MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!

    //MARK: - View Lifecycle
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
        
        ProgressHUDService.sharedInstance.showHUD(statusMessage: StringsService.getStringFor(key: "SelectNetworkLoadingPopupMessage"))
        
        NetworksDataService.sharedInstance.getAllStationData(apiUrl: Constants.CityBikes.NetworksAPI) {
            responseObject, error in
            
            let temp = responseObject
            self.networks = temp.sorted { $0.name! < $1.name! }
            
            ProgressHUDService.sharedInstance.dismissHUD()
        }

    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "SelectCityNavBarTitle")
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.FirstTimeUseCity, for: indexPath as IndexPath)
        
        cell.textLabel?.text = networks[indexPath.row].name
        cell.detailTextLabel?.text = (networks[indexPath.row].location?.city)! + ", " + CountryCleanupService.sharedInstance.mapCountryCodeToString(countryCode: (networks[indexPath.row].location?.country)!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Constants.SegueNames.GoToFirstTimeUseFinished, sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        let builtAPIURL = Constants.CityBikes.BaseAPIURL + networks[indexPath.row].href!
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: networks[indexPath.row].location?.city as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: networks[indexPath.row].name as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: builtAPIURL as AnyObject)
        
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.FTUCitySelected, customAttributes: [Constants.AnalyticEventDetail.CitySelected: networks[indexPath.row].name as AnyObject])
    }
}
