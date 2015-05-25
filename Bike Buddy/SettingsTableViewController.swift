//
//  SettingsTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {   
    //MARK: - View Outlets
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = UIApplication.versionBuild()
        cityLabel.text = SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_CITY_NAME_SETTINGS_KEY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if let cellReuseID = selectedCell.reuseIdentifier {
            switch cellReuseID {
            case "deleteData":
                let deleteDataActionSheet = UIAlertController(title: "Do you want to delete all of Bike Buddy's data? This will start the application from scratch again.", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                deleteDataActionSheet.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alertAction) -> Void in
                    SettingsService.sharedInstance.clearAllSettings()
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    
                    let storyboard: UIStoryboard = UIStoryboard(name: "FirstTimeUse", bundle: nil)
                    let firstVC: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
                    
                    self.presentViewController(firstVC, animated: true, completion: nil)
                }))
                deleteDataActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }))
                presentViewController(deleteDataActionSheet, animated: true, completion: nil)
            default: break
            }
        }

    }
}
