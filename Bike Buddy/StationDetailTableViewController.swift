//
//  StationDetailTableViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 3/19/16.
//  Copyright © 2016 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit
import BikeBuddyKit

class StationDetailTableViewController: UITableViewController {
    // MARK: - Class Variables

    var stationObject: Station!

    // MARK: - View Outlets

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

        mapView.delegate = self
        mapView.addAnnotation(stationObject)
        mapView.showAnnotations([stationObject], animated: false)
        
        setupUserActivity()
    }
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        let userInfo = ["stationId": stationObject.id,
                        "stationName": stationObject.stationName] as [String: Any]
        activity.addUserInfoEntries(from: userInfo)
        activity.requiredUserInfoKeys = ["stationId", "stationName"]
    }
    
    private func setupUserActivity() {
        let activity = NSUserActivity(activityType: Constants.UserActivity.StationActivityTypeIdentifier)
        activity.title = stationObject.stationName
        
        var keywords = stationObject.stationName.components(separatedBy: " ")
        keywords.append(stationObject.streetAddress)
        activity.keywords = Set(keywords)
        
        let userInfo = ["stationId": stationObject.id,
                        "stationName": stationObject.stationName] as [String: Any]
        activity.addUserInfoEntries(from: userInfo)
        activity.requiredUserInfoKeys = ["stationId", "stationName"]
        
        activity.isEligibleForHandoff = false
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = true
        
        userActivity = activity
        userActivity!.becomeCurrent()
    }

    private func setupTheme() {
        ThemeService.themeTextOnlyButton(textLabel: directionsToStationLabel)
        ThemeService.themeTextOnlyButton(textLabel: shareStationLabel)
    }

    private func setupStrings() {
        stationNameLabel.text = stationObject.stationName
        stationDistanceLabel.text = stationObject.approximateDistanceAwayFromUser + " " + StringsService.getStringFor(key: "GeneralAwayLabel")
        bikesAvailableLabel.text = NumberFormatter.localizedString(from: stationObject.availableBikes as NSNumber, number: .none) + " " + StringsService.getStringFor(key: "StationDetailBikesAvailable")
        docksAvailableLabel.text = NumberFormatter.localizedString(from: stationObject.availableDocks as NSNumber, number: .none) + " " + StringsService.getStringFor(key: "StationDetailDocksAvailable")

        navBarItem.title = StringsService.getStringFor(key: "StationDetailNavBarTitle")
        directionsToStationLabel.text = StringsService.getStringFor(key: "StationDetailDirectionsButton")
        shareStationLabel.text = StringsService.getStringFor(key: "StationDetailShareButton")
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath as IndexPath)!
        
        if let cellReuseID = selectedCell.reuseIdentifier {
            switch cellReuseID {
            case Constants.TableViewCellResuseIdentifier.StationDetailDirectionsToStation:
                userClickedOnDirectionsToStationButton()
            case Constants.TableViewCellResuseIdentifier.StationDetailShareStation:
                userClickedShareStation()
            default: break
            }
        }
        
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    // MARK: - User Actions

    private func userClickedOnDirectionsToStationButton() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.GetDirectionsToStation)
        
        let placemark: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(stationObject.latitude, stationObject.longitude), addressDictionary: nil)
        let mapItem: MKMapItem = MKMapItem(placemark: placemark)

        mapItem.name = stationObject.stationName

        var optionsDictonary = [String: String]()
        optionsDictonary[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeWalking

        mapItem.openInMaps(launchOptions: optionsDictonary)
    }

    private func userClickedShareStation() {
        AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.ShareStation)
        
        var sharingItems = [AnyObject]()
        sharingItems.append(stationObject.shareStringDescription as AnyObject)

        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension StationDetailTableViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: Constants.MapViewReuseIdentifier.StationDetail)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.MapViewReuseIdentifier.StationDetail)
            annotationView!.canShowCallout = false
            
            annotationView!.image = UIImage(named: "mapPin")
        }
        
        return annotationView
    }
}
