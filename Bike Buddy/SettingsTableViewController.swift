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

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var numberOfClosestStationsLabel: UILabel!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var serviceCityLabel: UILabel!
    @IBOutlet weak var serviceNumberOfClosestStationsLabel: UILabel!
    @IBOutlet weak var generalAboutLabel: UILabel!
    @IBOutlet weak var generalTellYourFriendsLabel: UILabel!
    @IBOutlet weak var generalRateTheAppLabel: UILabel!

    //MARK: - View Lifecycle


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.updateViewableStrings), name: Constants.NotificationCenterEvent.FirstTimeUseCompleted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.updateViewableStrings), name: Constants.NotificationCenterEvent.NewCitySelected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.updateViewableStrings), name: Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.NotificationCenterEvent.FirstTimeUseCompleted, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.NotificationCenterEvent.NewCitySelected, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated, object: nil)
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
        generalTellYourFriendsLabel.text = NSLocalizedString("SettingsGeneralTellYourFriends", comment: "")
        generalRateTheAppLabel.text = NSLocalizedString("SettingsGeneralRateApp", comment: "")
    }

    func updateViewableStrings() {
        cityLabel?.text = SettingsService.sharedInstance.getSettingAsString(Constants.SettingsKey.BikeServiceCityName)
        numberOfClosestStationsLabel?.text = SettingsService.sharedInstance.getSettingAsString(Constants.SettingsKey.NumberOfClosestStations)
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
            case Constants.TableViewCellResuseIdentifier.SettingsTellYourFriends:
                showTellYourFriendsActionSheet(indexPath, sender: selectedCell)
            case Constants.TableViewCellResuseIdentifier.SettingsRateApp:
                goToAppStorePage()
            default: break
            }
        }

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //MARK: - Table View Actions

    private func goToAppStorePage() {
        let url = NSURL(string: Constants.ExtneralURL.AppStoreDeepLink)
        UIApplication.sharedApplication().openURL(url!)
    }

    private func showTellYourFriendsActionSheet(indexPath: NSIndexPath, sender: UIView) {
        let sharingMessage = NSLocalizedString("SettingsShareMessageContent", comment: "") + " " + Constants.ExtneralURL.AppStoreDeepLink

        var sharingItems = [AnyObject]()
        sharingItems.append(sharingMessage)

        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)

        // Only for iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }

        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
