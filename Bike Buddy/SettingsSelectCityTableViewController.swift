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

        AnalyticsService.sharedInstance.pegUserAction("Tapped Select City in Settings")

        setupStrings()

        if let urlToCitiesPlist = NSBundle.mainBundle().URLForResource(Constants.CitiesPlist.FileName, withExtension: "plist") {
            if let citiesArrayFromFile = NSArray(contentsOfURL: urlToCitiesPlist) {
                for city in citiesArrayFromFile {
                    let newCity = City()

                    if let name = city.valueForKey(Constants.CitiesPlist.NameField) as? String {
                        newCity.name = name
                    }
                    if let serviceName = city.valueForKey(Constants.CitiesPlist.ServiceNameField) as? String {
                        newCity.serviceName = serviceName
                    }
                    if let apiUrl = city.valueForKey(Constants.CitiesPlist.APIURLField) as? String {
                        newCity.apiUrl = apiUrl
                    }

                    if newCity.isValid() {
                        citiesArray.append(newCity)
                    }
                }
            }
        }


        citiesArray.sortInPlace { (item1, item2) -> Bool in
            item1.name < item2.name
        }
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SettingsSelectCityNavBarTitle", comment: "")
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCellResuseIdentifier.SettingsCitySelect, forIndexPath: indexPath)

        cell.textLabel?.text = citiesArray[indexPath.row].name
        cell.detailTextLabel?.text = citiesArray[indexPath.row].serviceName

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let oldCity = SettingsService.sharedInstance.getSettingAsString(Constants.SettingsKey.BikeServiceCityName)
        let analyticAttr = ["Old City": oldCity, "New City": citiesArray[indexPath.row].name]
        AnalyticsService.sharedInstance.pegUserAction("Changed to new City", customAttributes: analyticAttr)

        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.BikeServiceCityName, value: citiesArray[indexPath.row].name)
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.BikeServiceName, value: citiesArray[indexPath.row].serviceName)
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.BikeServiceAPIURL, value: citiesArray[indexPath.row].apiUrl)

        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationCenterEvent.NewCitySelected, object: self)

        navigationController?.popViewControllerAnimated(true)
    }
}
