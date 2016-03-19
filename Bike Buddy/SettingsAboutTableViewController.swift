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
            case ABOUT_OPEN_SOURCE_ALMOFIRE_REUSE_IDENTIFIER:
                openWebView(OPEN_SOURCE_ALAMOFIRE_URL)
            case ABOUT_OPEN_SOURCE_OBJECTMAPPER_REUSE_IDENTIFIER:
                openWebView(OPEN_SOURCE_OBJECT_MAPPER_URL)
            case ABOUT_OPEN_SOURCE_AFOM_REUSE_IDENTIFIER:
                openWebView(OPEN_SOURCE_AFOM_URL)
            case ABOUT_OPEN_SOURCE_SVPROGRESSHUD_REUSE_IDENTIFIER:
                openWebView(OPEN_SOURCE_SVPROGRESSHUD_URL)
            case ABOUT_LEGAL_PRIVACY_POLICY_REUSE_IDENTIFIER:
                showPrivacyPolicy()
            default: break
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private func showPrivacyPolicy() {
        
    }
    
    private func openWebView(url: String) {
        if let url = NSURL(string: url) {
            let svc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            self.presentViewController(svc, animated: true) { () -> Void in
                // Need to do this hack becuase the Safari View Controller is buggy as hell with the swipe back gesture
                for view in svc.view.subviews {
                    if let recognisers = view.gestureRecognizers {
                        for gestureRecogniser in recognisers where gestureRecogniser is UIScreenEdgePanGestureRecognizer {
                            gestureRecogniser.enabled = false
                        }  
                    }  
                }
            }
        }
    }
}
