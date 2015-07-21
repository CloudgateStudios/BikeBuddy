//
//  SettingsTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import Social
import MessageUI

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
            case "rateBikeBuddy":
                goToAppStorePage()
            default: break
            }
        }
    }
    
    //MARK: - Table View Actions
    
    private func goToAppStorePage() {
        let url = NSURL(string: APP_STORE_URL)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    private func showTellYourFriendsActionSheet(indexPath: NSIndexPath) {
        let tellYourFriendsActionSheet = UIAlertController(title: nil, message: "Tell your friends about Bike Buddy", preferredStyle: .ActionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject("Check out Bike Share Buddy")
            mailViewController.setMessageBody(TELL_FRIENDS_MESSAGE_CONTENT, isHTML: true)
            
            self.presentViewController(mailViewController, animated: true, completion: nil)
        })
        
        let smsAction = UIAlertAction(title: "Text Message", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var smsViewController = MFMessageComposeViewController()
            smsViewController.body = TELL_FRIENDS_MESSAGE_CONTENT
            smsViewController.messageComposeDelegate = self
            
            self.presentViewController(smsViewController, animated: true, completion: nil)
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
        
        if(MFMailComposeViewController.canSendMail()) {
            tellYourFriendsActionSheet.addAction(emailAction)
        }
        if(MFMessageComposeViewController.canSendText()) {
            tellYourFriendsActionSheet.addAction(smsAction)
        }
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)) {
            tellYourFriendsActionSheet.addAction(facebookAction)
        }
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
            tellYourFriendsActionSheet.addAction(twitterAction)
        }
        
        if(tellYourFriendsActionSheet.actions.count != 0) {
            
            tellYourFriendsActionSheet.addAction(cancelAction)
        
            self.presentViewController(tellYourFriendsActionSheet, animated: true, completion: nil)
        }
        else {
            let noActionsAlert = UIAlertController(title: "No sharing actions", message: "You don't seem to have Email, SMS, Facebook, or Twitter setup on this device. Go to Settings to setup one of these accounts and then you can share.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
            noActionsAlert.addAction(alertAction)
            presentViewController(noActionsAlert, animated: true) {}
        }
    }
}

// MARK: - Mail Compose View Delegate

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Message Compose View Delegate

extension SettingsTableViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
