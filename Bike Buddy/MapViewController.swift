//
//  MapViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    //MARK: - Class Variables

    var tappedStation: Station!

    //MARK: - View Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var currentPositionButton: UIBarButtonItem!
    @IBOutlet weak var updatedAtLabel: UILabel!

    //MARK: - View Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.refreshMapAnnotations), name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()

        self.mapView.delegate = self
    }

    func setupStrings() {
        navBarItem.title = NSLocalizedString("MapNavBarTitle", comment: "")
    }

    func refreshMapAnnotations() {
        self.loadAnnotationsOnMapView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueNames.ShowStationDetailFromMap {
            if let vc = segue.destination as? StationDetailTableViewController {
                
                AnalyticsService.sharedInstance.pegUserAction(eventName: Constants.AnalyticEvent.LoadStationDetail, customAttributes: [Constants.AnalyticEventDetail.LoadedFrom: "Map View" as AnyObject])
                
                vc.stationObject = self.tappedStation
                
                self.tappedStation = nil
            }
        }
    }

    //MARK: - Actions

    @IBAction func currentPositionButtonTapped(_ sender: UIBarButtonItem) {
        AnalyticsService.sharedInstance.pegUserAction(eventName: "Current Position on Map Button Tapped")
        
        if !mapView.isUserLocationVisible {
            AnalyticsService.sharedInstance.pegUserAction(eventName: "Current Position on Map Button Tapped when Outside Map View")
            
            let alert = UIAlertController(title: NSLocalizedString("MapUserOutsideViewPopupTitle", comment: ""), message: NSLocalizedString("MapUserOutsideViewPopupMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            let alertActionOK = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in self.zoomMapToCurrentLocation()}
            let alertActionCancel = UIAlertAction(title: NSLocalizedString("GeneralButtonCancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(alertActionOK)
            alert.addAction(alertActionCancel)
            present(alert, animated: true) { () -> Void in }
        } else {
            zoomMapToCurrentLocation()
        }
    }
}

//MARK: - Map View

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: Constants.MapViewReuseIdentifier.FullMap)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.MapViewReuseIdentifier.FullMap)
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView =  UIButton(type: UIButtonType.detailDisclosure) as UIView
            
            annotationView!.image = UIImage(named: "mapPin")
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let station = view.annotation as? Station {
            self.tappedStation = station
            
            self.performSegue(withIdentifier: Constants.SegueNames.ShowStationDetailFromMap, sender: self)
        }
    }

    /**
    Take the current Stations.list and load the needed annotations on the map
    */
    func loadAnnotationsOnMapView() {
        ProgressHUDService.sharedInstance.dismissHUD()

        if let pins = mapView?.annotations {
            mapView.removeAnnotations(pins)
        }

        mapView?.addAnnotations(Stations.sharedInstance.list)
        mapView?.showAnnotations(Stations.sharedInstance.list, animated: true)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        updatedAtLabel.text = NSLocalizedString("MapUpdatedAtLabel", comment: "") + " " + dateFormatter.string(from: Stations.sharedInstance.lastUpdated as Date)
    }

    func zoomMapToCurrentLocation() {
        var region = MKCoordinateRegion()
        region.center = mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.05
        region.span.longitudeDelta = 0.05

        mapView?.setRegion(region, animated: true)
    }
}
