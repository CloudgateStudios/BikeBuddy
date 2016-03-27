//
//  SettingsAboutTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/19/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit
import SafariServices

class SettingsAboutTableViewController: UITableViewController {

    //MARK: - View Outlets
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var appNameAndVersionBottomLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStrings()
    }
    
    private func setupStrings() {
        navBarItem.title = NSLocalizedString("SettingsAboutNavBarTitle", comment: "")
        appNameAndVersionBottomLabel.text = UIApplication.appName() + " " + UIApplication.versionBuild()
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if let cellReuseID = selectedCell.reuseIdentifier {
            switch cellReuseID {
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyAlmaofire:
                openWebView(Constants.ExtneralURL.Alamofire)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyObjectMapper:
                openWebView(Constants.ExtneralURL.ObjectMapper)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartyAFOM:
                openWebView(Constants.ExtneralURL.AFOM)
            case Constants.TableViewCellResuseIdentifier.AboutThirdPartySVProgressHUD:
                openWebView(Constants.ExtneralURL.SVProgressHUD)
            default: break
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private func openWebView(url: String) {
        if let url = NSURL(string: url) {
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            svc.delegate = self
            self.presentViewController(svc, animated: true) {}
        }
    }
}

extension SettingsAboutTableViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
