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
    @IBOutlet weak var shareStationLabel: UILabel!
    @IBOutlet weak var directionsToStationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()
        setupTheme()

        mapView.addAnnotation(stationObject)
        mapView.showAnnotations([stationObject], animated: false)
    }

    private func setupTheme() {
        ThemeService.themeTextOnlyButton(directionsToStationLabel)
        ThemeService.themeTextOnlyButton(shareStationLabel)
    }

    private func setupStrings() {
        stationNameLabel.text = stationObject.stationName
        stationDistanceLabel.text = stationObject.approximateDistanceAwayFromUser + " " + NSLocalizedString("GeneralAwayLabel", comment: "")
        bikesAvailableLabel.text = NSNumberFormatter.localizedStringFromNumber(stationObject.availableBikes, numberStyle: .NoStyle) + " " + NSLocalizedString("StationDetailBikesAvailable", comment: "")
        docksAvailableLabel.text = NSNumberFormatter.localizedStringFromNumber(stationObject.availableDocks, numberStyle: .NoStyle) + " " + NSLocalizedString("StationDetailDocksAvailable", comment: "")

        navBarItem.title = NSLocalizedString("StationDetailNavBarTitle", comment: "")
        directionsToStationLabel.text = NSLocalizedString("StationDetailDirectionsButton", comment: "")
        shareStationLabel.text = NSLocalizedString("StationDetailShareButton", comment: "")
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!

        if let cellReuseID = selectedCell.reuseIdentifier {
            switch cellReuseID {
            case Constants.TableViewCellResuseIdentifier.StationDetailDirectionsToStation:
                userClickedOnDirectionsToStationButton()
            case Constants.TableViewCellResuseIdentifier.StationDetailShareStation:
                userClickedShareStation()
            default: break
            }
        }

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //MARK: - Map View

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.MapViewReuseIdentifier.StationDetail)
        annotationView.animatesDrop = false

        return annotationView
    }

    //MARK: - User Actions

    private func userClickedOnDirectionsToStationButton() {
        let placemark: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(stationObject.latitude, stationObject.longitude), addressDictionary: nil)
        let mapItem: MKMapItem = MKMapItem(placemark: placemark)

        mapItem.name = stationObject.stationName

        var optionsDictonary = [String: String]()
        optionsDictonary[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeWalking

        mapItem.openInMapsWithLaunchOptions(optionsDictonary)
    }

    private func userClickedShareStation() {
        var sharingItems = [AnyObject]()
        sharingItems.append(stationObject.shareStringDescription)

        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
