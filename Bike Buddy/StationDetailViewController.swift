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
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    //MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.addAnnotation(stationObject)
        mapView.showAnnotations([stationObject], animated: false)
        stationNameLabel.text = stationObject.stationName
        stationDistanceLabel.text = stationObject.distanceFromUserInMiles.format(".2")
        
        if(stationObject.isFavorite) {
            favoriteButton.image = UIImage(named: FAVORITE_NAV_BAR_ICON_NAME)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Map View
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: STATION_DETAIL_MAP_RESUE_IDENTIFIER)
        annotationView.animatesDrop = false
        
        return annotationView
    }
    
    //MARK: - User Actions
    
    @IBAction func userClickedOnDirectionsToStationButton(sender: UIButton) {
        var placemark: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(stationObject.latitude, stationObject.longitude), addressDictionary: nil)
        var mapItem: MKMapItem = MKMapItem(placemark: placemark)
        
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
    
    @IBAction func userClickedFavoriteButton(sender: UIBarButtonItem) {

    }
}