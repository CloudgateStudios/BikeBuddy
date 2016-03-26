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
    
    private var tappedStation: Station!
    
    //MARK: - View Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var currentPositionButton: UIBarButtonItem!
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.refreshMapAnnotations), name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == Constants.SegueNames.ShowStationDetailFromMap) {
            let vc = (segue.destinationViewController as! StationDetailTableViewController)
            vc.stationObject = self.tappedStation
            
            self.tappedStation = nil
        }
    }
    
    //MARK: - Actions
    
    @IBAction func currentPositionButtonTapped(sender: UIBarButtonItem) {
        if(!mapView.userLocationVisible) {
            let alert = UIAlertController(title: NSLocalizedString("MapUserOutsideViewPopupTitle", comment: ""), message: NSLocalizedString("MapUserOutsideViewPopupMessage", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            let alertActionOK = UIAlertAction(title: NSLocalizedString("GeneralButtonOK", comment: ""), style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in self.zoomMapToCurrentLocation()}
            let alertActionCancel = UIAlertAction(title: NSLocalizedString("GeneralButtonCancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(alertActionOK)
            alert.addAction(alertActionCancel)
            presentViewController(alert, animated: true) { () -> Void in }
        }
        else {
            self.zoomMapToCurrentLocation()
        }
    }
}

//MARK: - Map View

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: FULL_MAP_VEIW_MAP_REUSE_IDENTIFIER)
        annotationView.animatesDrop = false
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView =  UIButton(type: UIButtonType.DetailDisclosure) as UIView
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.tappedStation = view.annotation as! Station
        
        self.performSegueWithIdentifier(Constants.SegueNames.ShowStationDetailFromMap, sender: self)
    }
    
    /**
    Take the current Stations.list and load the needed annotations on the map
    */
    private func loadAnnotationsOnMapView() {
        ProgressHUDService.sharedInstance.dismissHUD()
        
        if let pins = mapView?.annotations {
            mapView.removeAnnotations(pins)
        }

        mapView?.addAnnotations(Stations.sharedInstance.list)
        mapView?.showAnnotations(Stations.sharedInstance.list, animated: true)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        updatedAtLabel.text = NSLocalizedString("MapUpdatedAtLabel", comment: "") + " " + dateFormatter.stringFromDate(Stations.sharedInstance.lastUpdated)
    }
    
    private func zoomMapToCurrentLocation() {
        var region = MKCoordinateRegion()
        region.center = mapView.userLocation.coordinate
        region.span.latitudeDelta = 0.05
        region.span.longitudeDelta = 0.05
        
        mapView?.setRegion(region, animated: true)
    }
}
