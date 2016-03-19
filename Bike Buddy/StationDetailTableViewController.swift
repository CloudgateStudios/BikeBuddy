//
//  StationDetailTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/19/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit

class StationDetailTableViewController: UITableViewController {
    
    //MARK: - Class Variables
    
    var stationObject: Station!
    
    //MARK: - View Outlets
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stationDistanceLabel: UILabel!
    @IBOutlet weak var bikesAvailableLabel: UILabel!
    @IBOutlet weak var docksAvailableLabel: UILabel!
    @IBOutlet weak var navBarItem: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        
        setupStrings()
        
        mapView.addAnnotation(stationObject)
        mapView.showAnnotations([stationObject], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupTheme() {
        /*ThemeService.themeButton(shareStationButton)
        ThemeService.themeButton(directionToStationsButton)*/
    }
    
    private func setupStrings() {
        stationNameLabel.text = stationObject.stationName
        stationDistanceLabel.text = stationObject.approximateDistanceAwayFromUser + " " + NSLocalizedString("GeneralAwayLabel", comment: "")
        bikesAvailableLabel.text = NSNumberFormatter.localizedStringFromNumber(stationObject.availableBikes, numberStyle: .NoStyle) + " " + NSLocalizedString("StationDetailBikesAvailable", comment: "")
        docksAvailableLabel.text = NSNumberFormatter.localizedStringFromNumber(stationObject.availableDocks, numberStyle: .NoStyle) + " " + NSLocalizedString("StationDetailDocksAvailable", comment: "")
        
        navBarItem.title = NSLocalizedString("StationDetailNavBarTitle", comment: "")
        /*shareStationButton.setTitle(NSLocalizedString("StationDetailShareButton", comment: ""), forState: .Normal)
        directionToStationsButton.setTitle(NSLocalizedString("StationDetailDirectionsButton", comment: ""), forState: .Normal)*/
    }

    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //MARK: - Map View
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: STATION_DETAIL_MAP_RESUE_IDENTIFIER)
        annotationView.animatesDrop = false
        
        return annotationView
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
