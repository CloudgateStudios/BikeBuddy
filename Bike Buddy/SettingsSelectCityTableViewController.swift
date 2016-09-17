//
//  SettingsSelectCityTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/25/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class SettingsSelectCityTableViewController: UITableViewController {
    //MARK: - Class Variables

    var citiesArray = [City]()

    //MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!

    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsSelectCity)

        setupStrings()

        if let urlToCitiesPlist = Bundle.main.url(forResource: Constants.CitiesPlist.FileName, withExtension: "plist") {
            if let citiesArrayFromFile = NSArray(contentsOf: urlToCitiesPlist) {
                for city in citiesArrayFromFile {
                    let newCity = City()

                    if let name = (city as AnyObject).value(forKey: Constants.CitiesPlist.NameField) as? String {
                        newCity.name = name
                    }
                    if let serviceName = (city as AnyObject).value(forKey:Constants.CitiesPlist.ServiceNameField) as? String {
                        newCity.serviceName = serviceName
                    }
                    if let apiUrl = (city as AnyObject).value(forKey:Constants.CitiesPlist.APIURLField) as? String {
                        newCity.apiUrl = apiUrl
                    }

                    if newCity.isValid() {
                        citiesArray.append(newCity)
                    }
                }
            }
        }


        citiesArray.sort { (item1, item2) -> Bool in
            item1.name < item2.name
        }
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SettingsSelectCityNavBarTitle", comment: "")
    }

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.SettingsCitySelect, for: indexPath as IndexPath)
        
        cell.textLabel?.text = citiesArray[indexPath.row].name
        cell.detailTextLabel?.text = citiesArray[indexPath.row].serviceName
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldCity = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceCityName)
        let analyticAttr = [Constants.AnalyticEventDetail.OldCity: oldCity, Constants.AnalyticEventDetail.NewCity: citiesArray[indexPath.row].name]
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.SelectNewCity, customAttributes: analyticAttr as [String : AnyObject])
        
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: citiesArray[indexPath.row].name as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: citiesArray[indexPath.row].serviceName as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: citiesArray[indexPath.row].apiUrl as AnyObject)
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: self)
        
        _ = navigationController?.popViewController(animated: true)
    }
}
