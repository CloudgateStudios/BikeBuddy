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
    
    //MARK: - View Lifecycle
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let urlToCitiesPlist = NSBundle.mainBundle().URLForResource("Cities", withExtension: "plist") {
            if let citiesArrayFromFile = NSArray(contentsOfURL: urlToCitiesPlist) {
                for city in citiesArrayFromFile {
                    var newCity = City()
                    
                    newCity.name = city.valueForKey("name") as! String
                    newCity.serviceName = city.valueForKey("serviceName") as! String
                    newCity.apiUrl = city.valueForKey("apiUrl") as! String
                    
                    citiesArray.append(newCity)
                }
            }
        }
        
        citiesArray.sort { (item1, item2) -> Bool in
            item1.name < item2.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FTUCityServiceCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = citiesArray[indexPath.row].name
        cell.detailTextLabel?.text = citiesArray[indexPath.row].serviceName

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow()!
        
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_CITY_NAME_SETTINGS_KEY, value: citiesArray[indexPath.row].name)
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_NAME_SETTINGS_KEY, value: citiesArray[indexPath.row].serviceName)
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_API_URL_SETTINGS_KEY, value: citiesArray[indexPath.row].apiUrl)
    }
}
