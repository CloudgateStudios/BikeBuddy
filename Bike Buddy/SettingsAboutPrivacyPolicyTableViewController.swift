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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PrivacyPolicyCell", forIndexPath: indexPath)

        // Configure the cell...
        
        if let filepath = NSBundle.mainBundle().pathForResource("PrivacyPolicy", ofType: "txt") {
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
