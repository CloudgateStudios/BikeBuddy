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
import BikeBuddyKit

class SettingsTableViewController: UITableViewController {
    // MARK: - View Outlets

    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var numberOfClosestStationsLabel: UILabel!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var serviceNetworkLabel: UILabel!
    @IBOutlet weak var serviceNumberOfClosestStationsLabel: UILabel!
    @IBOutlet weak var generalAboutLabel: UILabel!
    @IBOutlet weak var generalTellYourFriendsLabel: UILabel!
    @IBOutlet weak var generalRateTheAppLabel: UILabel!

    // MARK: - View Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.updateViewableStrings), name: NSNotification.Name(Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.updateViewableStrings), name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.updateViewableStrings), name: NSNotification.Name(Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.FirstTimeUseCompleted), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.NewCitySelected), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(Constants.NotificationCenterEvent.NumberOfClosestStationsUpdated), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
    }

    private func setupStrings() {
        updateViewableStrings()

        navBarItem.title = StringsService.getStringFor(key: "SettingsNavBarTitle")
        serviceNetworkLabel.text = StringsService.getStringFor(key: "SettingsServiceNetwork")
        serviceNumberOfClosestStationsLabel.text = StringsService.getStringFor(key: "SettingsServiceNumberOfStations")
        generalAboutLabel.text = StringsService.getStringFor(key: "SettingsGeneralAbout")
        generalTellYourFriendsLabel.text = StringsService.getStringFor(key: "SettingsGeneralTellYourFriends")
        generalRateTheAppLabel.text = StringsService.getStringFor(key: "SettingsGeneralRateApp")
    }

    @objc func updateViewableStrings() {
        networkLabel?.text = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.BikeServiceName)
        numberOfClosestStationsLabel?.text = SettingsService.sharedInstance.getSettingAsString(key: Constants.SettingsKey.NumberOfClosestStations)
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return StringsService.getStringFor(key: "SettingsServiceGroup")
        case 1:
            return StringsService.getStringFor(key: "SettingsGeneralGroup")
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath as IndexPath)!
        
        if let cellReuseID = selectedCell.reuseIdentifier {
            switch cellReuseID {
            case Constants.TableViewCellResuseIdentifier.SettingsTellYourFriends:
                showTellYourFriendsActionSheet(indexPath: indexPath as NSIndexPath, sender: selectedCell)
            case Constants.TableViewCellResuseIdentifier.SettingsRateApp:
                goToAppStorePage()
            default: break
            }
        }
        
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)

    }

    // MARK: - Table View Actions

    private func goToAppStorePage() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.GoToAppStoreLink)
        
        let url = NSURL(string: Constants.ExtneralURL.AppStoreDeepLink)
        UIApplication.shared.open(url! as URL, completionHandler: nil)
    }

    private func showTellYourFriendsActionSheet(indexPath: NSIndexPath, sender: UIView) {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.ShareAppWithFriends)
        
        let sharingMessage = StringsService.getStringFor(key: "SettingsShareMessageContent") + " " + Constants.ExtneralURL.AppStoreDeepLink

        var sharingItems = [AnyObject]()
        sharingItems.append(sharingMessage as AnyObject)

        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)

        // Only for iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
}
