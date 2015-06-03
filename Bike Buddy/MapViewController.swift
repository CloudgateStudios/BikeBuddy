//
//  MapViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    //MARK: - Class Variables
    
    private var tappedStation: Station!
    
    //MARK: - View Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        setupUI()
    }
    
    func setupUI() {
        self.loadAnnotationsOnMapView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showStationDetailFromMap") {
            var vc = (segue.destinationViewController as! StationDetailViewController)
            vc.stationObject = self.tappedStation
            
            self.tappedStation = nil
        }
    }
    
    //MARK: - Map View
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "FullMapPinID")
        annotationView.animatesDrop = false
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView =  UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIView
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        //showStationDetailFromMap
        //MapViewAnnotation *annotationTapped = (MapViewAnnotation *)view.annotation;
        
        self.tappedStation = view.annotation as! Station
        
        self.performSegueWithIdentifier("showStationDetailFromMap", sender: self)
    }
    
    /** 
        Take the current Stations.list and load the needed annotations on the map
    */
    private func loadAnnotationsOnMapView() {
        if let pins = mapView?.annotations {
            mapView.removeAnnotations(pins)
        }
        
        mapView?.addAnnotations(Stations.sharedInstance.list)
        mapView?.showAnnotations(Stations.sharedInstance.list, animated: true)
    }
}
