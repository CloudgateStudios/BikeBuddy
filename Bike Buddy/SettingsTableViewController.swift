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
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var serviceCityLabel: UILabel!
    @IBOutlet weak var serviceNumberOfClosestStationsLabel: UILabel!
    @IBOutlet weak var generalAboutLabel: UILabel!
    @IBOutlet weak var generalVersionLabel: UILabel!
    @IBOutlet weak var generalTellYourFriendsLabel: UILabel!
    @IBOutlet weak var generalRateTheAppLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateViewableStrings", name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateViewableStrings", name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateViewableStrings", name: NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NEW_CITY_SELECTED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_NUMBER_OF_CLOSEST_STATIONS_UPDATED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
    }
    
    private func setupStrings() {
        updateViewableStrings()
        
        navBarItem.title = NSLocalizedString("SettingsNavBarTitle", comment: "")
        serviceCityLabel.text = NSLocalizedString("SettingsServiceCity", comment: "")
        serviceNumberOfClosestStationsLabel.text = NSLocalizedString("SettingsServiceNumberOfStations", comment: "")
        generalAboutLabel.text = NSLocalizedString("SettingsGeneralAbout", comment: "")
        generalVersionLabel.text = NSLocalizedString("SettingsGeneralVersion", comment: "")
        generalTellYourFriendsLabel.text = NSLocalizedString("SettingsGeneralTellYourFriends", comment: "")
        generalRateTheAppLabel.text = NSLocalizedString("SettingsGeneralRateApp", comment: "")
    }
    
    func updateViewableStrings() {
        versionLabel?.text = UIApplication.versionBuild()
        cityLabel?.text = SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_CITY_NAME_SETTINGS_KEY)
        numberOfClosestStationsLabel?.text = SettingsService.sharedInstance.getSettingAsString(NUMBER_OF_CLOSEST_STATIONS_SETTINGS_KEY)
    }
    
    //MARK: - Table View
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SettingsServiceGroup", comment: "")
        case 1:
            return NSLocalizedString("SettingsGeneralGroup", comment: "")
        default:
            return ""
        }
    }
    
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
        let sharingMessage = NSLocalizedString("SettingsShareMessageContent", comment: "")
        
        let tellYourFriendsActionSheet = UIAlertController(title: nil, message: NSLocalizedString("SettingsShareActionSheetTitle", comment: ""), preferredStyle: .ActionSheet)
        
        let emailAction = UIAlertAction(title: NSLocalizedString("SettingsShareEmail", comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject(NSLocalizedString("SettingsShareMessageTitle", comment: ""))
            mailViewController.setMessageBody(sharingMessage, isHTML: true)
            
            self.presentViewController(mailViewController, animated: true, completion: nil)
        })
        
        let smsAction = UIAlertAction(title: NSLocalizedString("SettingsShareTextMessage", comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var smsViewController = MFMessageComposeViewController()
            smsViewController.body = sharingMessage
            smsViewController.messageComposeDelegate = self
            
            self.presentViewController(smsViewController, animated: true, completion: nil)
        })
        
        let facebookAction = UIAlertAction(title: NSLocalizedString("SettingsShareFacebook", comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var facebookDialog = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookDialog.completionHandler = {
                result -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            facebookDialog.setInitialText(sharingMessage)
            
            self.presentViewController(facebookDialog, animated: true, completion: nil)
        })
        
        let twitterAction = UIAlertAction(title: NSLocalizedString("SettingsShareTwitter", comment: ""), style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var twitterDialog = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            twitterDialog.completionHandler = {
                result -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            twitterDialog.setInitialText(sharingMessage)
            
            self.presentViewController(twitterDialog, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("GeneralButtonCancel", comment: ""), style: .Cancel, handler: {
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
            let noActionsAlert = UIAlertController(title: NSLocalizedString("SettingsShareNoServicesMessageBoxTitle",comment: ""), message: NSLocalizedString("SettingsShareNoServicesMessageBoxContent", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
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
