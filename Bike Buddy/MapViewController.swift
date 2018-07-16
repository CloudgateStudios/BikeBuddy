//
//  MapViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit
import BikeBuddyKit

class MapViewController: UIViewController {
    // MARK: - Class Variables

    var tappedStation: Station!
    var userActivityToRestore: NSUserActivity?

    // MARK: - View Outlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var currentPositionButton: UIBarButtonItem!
    @IBOutlet weak var updatedAtLabel: UILabel!

    // MARK: - View Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.refreshMapAnnotations), name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.actuallyRestoreState), name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.MapViewAnnotationsDrawComplete), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.StationsListUpdated), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.MapViewAnnotationsDrawComplete), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStrings()

        self.mapView.delegate = self
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        userActivityToRestore = activity
        
        if Stations.sharedInstance.list.count == 0 {
            return
        } else {
            actuallyRestoreState()
        }
        
    }
    
    @objc func actuallyRestoreState() {
        if userActivityToRestore != nil {
            if let previousStationName = userActivityToRestore?.userInfo!["stationName"] as? String {
                if let previousStation = Stations.getStationByName(name: previousStationName) {
                    self.tappedStation = previousStation
                    
                    if self.isViewLoaded && (self.view.window != nil) {
                        performSegue(withIdentifier: Constants.SegueNames.ShowStationDetailFromMap, sender: nil)
                    } else {
                        navigationController?.popViewController(animated: true)
                        performSegue(withIdentifier: Constants.SegueNames.ShowStationDetailFromMap, sender: nil)
                    }
                }
            }
        }
    }

    func setupStrings() {
        navBarItem.title = StringsService.getStringFor(key: "MapNavBarTitle")
    }

    @objc func refreshMapAnnotations() {
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

    // MARK: - Actions

    @IBAction func currentPositionButtonTapped(_ sender: UIBarButtonItem) {
        AnalyticsService.sharedInstance.pegUserAction(eventName: "Current Position on Map Button Tapped")
        
        if !mapView.userLocation.coordinate.isCurrentUserLocationReal() {
            let alert = UIAlertController(title: StringsService.getStringFor(key: "MapNoLocationFoundAlertTitle"), message: StringsService.getStringFor(key: "MapNoLocationFoundAlertMessage"), preferredStyle: UIAlertController.Style.alert)
            let alertActionOK = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertAction.Style.default)
            alert.addAction(alertActionOK)
            present(alert, animated: true) { () -> Void in }
        }
        
        if !mapView.isUserLocationVisible {
            AnalyticsService.sharedInstance.pegUserAction(eventName: "Current Position on Map Button Tapped when Outside Map View")
            
            let alert = UIAlertController(title: StringsService.getStringFor(key: "MapUserOutsideViewPopupTitle"), message: StringsService.getStringFor(key: "MapUserOutsideViewPopupMessage"), preferredStyle: UIAlertController.Style.alert)
            let alertActionOK = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonOK"), style: UIAlertAction.Style.default) { (_) -> Void in self.zoomMapToCurrentLocation()}
            let alertActionCancel = UIAlertAction(title: StringsService.getStringFor(key: "GeneralButtonCancel"), style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(alertActionOK)
            alert.addAction(alertActionCancel)
            present(alert, animated: true) { () -> Void in }
        } else {
            zoomMapToCurrentLocation()
        }
    }
}

// MARK: - Map View

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: Constants.MapViewReuseIdentifier.FullMap)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.MapViewReuseIdentifier.FullMap)
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView =  UIButton(type: UIButton.ButtonType.detailDisclosure) as UIView
            
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
        updatedAtLabel.text = StringsService.getStringFor(key: "MapUpdatedAtLabel") + " " + dateFormatter.string(from: Stations.sharedInstance.lastUpdated as Date)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationCenterEvent.MapViewAnnotationsDrawComplete), object: self)
    }

    func zoomMapToCurrentLocation() {
        var region = MKCoordinateRegion()
        region.center = mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.05
        region.span.longitudeDelta = 0.05

        mapView?.setRegion(region, animated: true)
    }
}
