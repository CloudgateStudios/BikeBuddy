//
//  SettingsTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import Social

class SettingsTableViewController: UITableViewController {   
    //MARK: - View Outlets
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var numberOfClosestStationsLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupUI() {
        versionLabel?.text = UIApplication.versionBuild()
        cityLabel?.text = SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_CITY_NAME_SETTINGS_KEY)
        numberOfClosestStationsLabel?.text = SettingsService.sharedInstance.getSettingAsString(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY)
    }
    
    //MARK: - Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if let cellReuseID = selectedCell.reuseIdentifier {
            switch cellReuseID {
            case "tellYourFriends":
                showTellYourFriendsActionSheet(indexPath)
            default: break
            }
        }

    }
    
    private func showTellYourFriendsActionSheet(indexPath: NSIndexPath) {
        let tellYourFriendsActionSheet = UIAlertController(title: nil, message: "Tell your friends about Bike Buddy", preferredStyle: .ActionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let smsAction = UIAlertAction(title: "Text Message", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var facebookDialog = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookDialog.completionHandler = {
                result -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            facebookDialog.setInitialText(TELL_FRIENDS_MESSAGE_CONTENT)
            
            self.presentViewController(facebookDialog, animated: true, completion: nil)
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var twitterDialog = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            twitterDialog.completionHandler = {
                result -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            twitterDialog.setInitialText(TELL_FRIENDS_MESSAGE_CONTENT)
            
            self.presentViewController(twitterDialog, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        })
        
        tellYourFriendsActionSheet.addAction(emailAction)
        tellYourFriendsActionSheet.addAction(smsAction)
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
            tellYourFriendsActionSheet.addAction(facebookAction)
        }
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
            tellYourFriendsActionSheet.addAction(twitterAction)
        }
        tellYourFriendsActionSheet.addAction(cancelAction)
        
        self.presentViewController(tellYourFriendsActionSheet, animated: true, completion: nil)
    }
}
