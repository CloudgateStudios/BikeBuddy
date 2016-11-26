//
//  SettingsAboutTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/19/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit
import SafariServices
import BikeBuddyKit

class SettingsAboutTableViewController: UITableViewController {

    //MARK: - View Outlets

    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var appNameAndVersionBottomLabel: UILabel!
    @IBOutlet weak var cityBikesLineOneLabel: UILabel!
    @IBOutlet weak var cityBikesLineTwoLabel: UILabel!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenSettingsAbout)

        setupStrings()
    }

    private func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "SettingsAboutNavBarTitle")
        appNameAndVersionBottomLabel.text = UIApplication.appName() + " " + UIApplication.versionBuild()
        cityBikesLineOneLabel.text = StringsService.getStringFor(key: "SettingsAboutCityBikesLineOne")
        cityBikesLineTwoLabel.text = StringsService.getStringFor(key: "SettingsAboutCityBikesLineTwo")
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath as IndexPath)!
        
        if let cellReuseID = selectedCell.reuseIdentifier {
            let analyticAttr = [Constants.AnalyticEventDetail.ThirdPartySoftwareName: cellReuseID]
            AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenThirdPartySoftware, customAttributes: analyticAttr as [String : AnyObject])
            
            switch cellReuseID {
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyAlmaofire:
                openWebView(url: Constants.ExtneralURL.Alamofire)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyObjectMapper:
                openWebView(url: Constants.ExtneralURL.ObjectMapper)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyAFOM:
                openWebView(url: Constants.ExtneralURL.AFOM)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartySVProgressHUD:
                openWebView(url: Constants.ExtneralURL.SVProgressHUD)
            case Constants.TableViewCellResuseIdentifier.AboutThridPartyFabric:
                openWebView(url: Constants.ExtneralURL.Fabric)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyDZN:
                openWebView(url: Constants.ExtneralURL.DZNEmptyDataSet)
            default: break
            }
        }
        
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    private func openWebView(url: String) {
        if let url = NSURL(string: url) {
            let svc = SFSafariViewController(url: url as URL, entersReaderIfAvailable: true)
            svc.delegate = self
            self.present(svc, animated: true) {}
        }
    }
}

extension SettingsAboutTableViewController: SFSafariViewControllerDelegate {    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
