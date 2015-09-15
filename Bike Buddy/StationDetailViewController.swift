//
//  StationDetailViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 6/2/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit

class StationDetailViewController: UIViewController, MKMapViewDelegate {
    //MARK: - Class Variables
    
    var stationObject: Station!
    
    //MARK: - View Outlets
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stationDistanceLabel: UILabel!
    @IBOutlet weak var shareStationButton: UIButton!
    @IBOutlet weak var directionToStationsButton: UIButton!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var bikesAvailableLabel: UILabel!
    @IBOutlet weak var docksAvailableLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTheme()
        setupStrings()

        mapView.addAnnotation(stationObject)
        mapView.showAnnotations([stationObject], animated: false)
    }
    
    private func setupTheme() {
        ThemeService.themeButton(shareStationButton)
        ThemeService.themeButton(directionToStationsButton)
    }
    
    private func setupStrings() {
        stationNameLabel.text = stationObject.stationName
        stationDistanceLabel.text = stationObject.approximateDistanceAwayFromUser
        bikesAvailableLabel.text = NSNumberFormatter.localizedStringFromNumber(stationObject.availableBikes, numberStyle: .NoStyle) + " " + NSLocalizedString("StationDetailBikesAvailable", comment: "")
        docksAvailableLabel.text = NSNumberFormatter.localizedStringFromNumber(stationObject.availableDocks, numberStyle: .NoStyle) + " " + NSLocalizedString("StationDetailDocksAvailable", comment: "")
        
        navBarItem.title = NSLocalizedString("StationDetailNavBarTitle", comment: "")
        shareStationButton.setTitle(NSLocalizedString("StationDetailShareButton", comment: ""), forState: .Normal)
        directionToStationsButton.setTitle(NSLocalizedString("StationDetailDirectionsButton", comment: ""), forState: .Normal)
    }
    
    //MARK: - Map View
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: STATION_DETAIL_MAP_RESUE_IDENTIFIER)
        annotationView.animatesDrop = false
        
        return annotationView
    }
    
    //MARK: - User Actions
    
    @IBAction func userClickedOnDirectionsToStationButton(sender: UIButton) {
        let placemark: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(stationObject.latitude, stationObject.longitude), addressDictionary: nil)
        let mapItem: MKMapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = stationObject.stationName
        
        var optionsDictonary = [String: String]()
        optionsDictonary[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeWalking

        mapItem.openInMapsWithLaunchOptions(optionsDictonary)
    }
    
    @IBAction func userClickedShareStation(sender: UIButton) {
        var sharingItems = [AnyObject]()
        sharingItems.append(stationObject.shareStringDescription)
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}