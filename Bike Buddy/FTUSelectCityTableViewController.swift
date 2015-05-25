//
//  FTUSelectCityTableViewController.swift
//  Bike Buddy
//
//  Created by Arra Tom, US-L-4 on 5/22/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import Foundation

class FTUSelectCityTableViewController: UITableViewController {
    var citiesArray = [City]()
    
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
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return citiesArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FTUCityServiceCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = citiesArray[indexPath.row].name
        cell.detailTextLabel?.text = citiesArray[indexPath.row].serviceName

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        let indexPath = self.tableView.indexPathForSelectedRow()!
        
        println(citiesArray[indexPath.row])
        
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_CITY_NAME_SETTINGS_KEY, value: citiesArray[indexPath.row].name)
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_NAME_SETTINGS_KEY, value: citiesArray[indexPath.row].serviceName)
        SettingsService.sharedInstance.saveSetting(BIKE_SERVICE_API_URL_SETTINGS_KEY, value: citiesArray[indexPath.row].apiUrl)
    }
    

}
