//
//  SettingsAboutPrivacyPolicyTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/20/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit

class SettingsAboutPrivacyPolicyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.OpenAboutPrivacyPolicy)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellResuseIdentifier.AboutPrivacyPolicy, for: indexPath as IndexPath)

        // Configure the cell...

        if let filepath = Bundle.main.path(forResource: Constants.PrivacyPolicyFile.FileName, ofType: Constants.PrivacyPolicyFile.FileExtension) {
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                cell.textLabel!.text =  contents
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }

        return cell
    }
}
