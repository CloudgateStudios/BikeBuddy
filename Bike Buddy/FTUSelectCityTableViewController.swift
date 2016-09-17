//
//  FTUSelectCityTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import Foundation

class FTUSelectCityTableViewController: UITableViewController {
    //MARK: - Class Variables

    var citiesArray = [City]()

    //MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!

    //MARK: - View Lifecycle
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()

        if let urlToCitiesPlist = Bundle.main.url(forResource: Constants.CitiesPlist.FileName, withExtension: "plist") {
            if let citiesArrayFromFile = NSArray(contentsOf: urlToCitiesPlist) {
                for city in citiesArrayFromFile {
                    let newCity = City()

                    //if let name = city.valueForKey(Constants.CitiesPlist.NameField) as? String {
                    if let name = (city as AnyObject).value(forKey: Constants.CitiesPlist.NameField) as? String {
                        newCity.name = name
                    }
                    if let serviceName = (city as AnyObject).value(forKey: Constants.CitiesPlist.ServiceNameField) as? String {
                        newCity.serviceName = serviceName
                    }
                    if let apiUrl = (city as AnyObject).value(forKey: Constants.CitiesPlist.APIURLField) as? String {
                        newCity.apiUrl = apiUrl
                    }

                    if newCity.isValid() {
                        citiesArray.append(newCity)
                    }
                }
            }
        }
        
        citiesArray.sort { $0.name < $1.name }
    }

    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SelectCityNavBarTitle", comment: "")
    }

    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.FirstTimeUseCity, for: indexPath as IndexPath)
        
        cell.textLabel?.text = citiesArray[indexPath.row].name
        cell.detailTextLabel?.text = citiesArray[indexPath.row].serviceName
        
        return cell
    }

    // MARK: - Navigation

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow!

        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceCityName, value: citiesArray[indexPath.row].name as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceName, value: citiesArray[indexPath.row].serviceName as AnyObject)
        SettingsService.sharedInstance.saveSetting(key: Constants.SettingsKey.BikeServiceAPIURL, value: citiesArray[indexPath.row].apiUrl as AnyObject)
        
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.FTUCitySelected, customAttributes: [Constants.AnalyticEventDetail.CitySelected: citiesArray[indexPath.row].name as AnyObject])
    }
}
