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
    
        if let urlToCitiesPlist = NSBundle.mainBundle().URLForResource(CITIES_PLIST_FILE_NAME, withExtension: "plist") {
            if let citiesArrayFromFile = NSArray(contentsOfURL: urlToCitiesPlist) {
                for city in citiesArrayFromFile {
                    let newCity = City()
                    
                    newCity.name = city.valueForKey(CITIES_PLIST_NAME_FIELD_KEY) as! String
                    newCity.serviceName = city.valueForKey(CITIES_PLIST_SERVICE_NAME_FIELD_KEY) as! String
                    newCity.apiUrl = city.valueForKey(CITIES_PLIST_API_URL_FIELD_KEY) as! String
                    
                    citiesArray.append(newCity)
                }
            }
        }
        
        citiesArray.sortInPlace { (item1, item2) -> Bool in
            item1.name < item2.name
        }
    }
    
    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SelectCityNavBarTitle", comment: "")
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FTU_CITY_SERVICE_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) 

        cell.textLabel?.text = citiesArray[indexPath.row].name
        cell.detailTextLabel?.text = citiesArray[indexPath.row].serviceName

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.BikeServiceCityName, value: citiesArray[indexPath.row].name)
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.BikeServiceName, value: citiesArray[indexPath.row].serviceName)
        SettingsService.sharedInstance.saveSetting(Constants.SettingsKey.BikeServiceAPIURL, value: citiesArray[indexPath.row].apiUrl)
    }
}
