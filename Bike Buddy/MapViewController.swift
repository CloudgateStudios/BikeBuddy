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
    
    var stationsArray = [Station]()
    
    //MARK: - View Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "setupUI", name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
    }
    
    deinit {
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_CENTER_FIRST_TIME_USE_COMPLETED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        setupUI()
    }
    
    func setupUI() {
        StationsDataService.sharedInstance.getAllStationData(SettingsService.sharedInstance.getSettingAsString(BIKE_SERVICE_API_URL_SETTINGS_KEY)) {
            responseObject, error in
            
            self.stationsArray = responseObject
            self.loadAnnotationsOnMapView()
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
        
        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "FullMapPinID")
        annotationView.animatesDrop = false
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    /** 
        Take the current stationsArray and load the needed annotations on the map
    */
    private func loadAnnotationsOnMapView() {
        mapView.addAnnotations(stationsArray)
        mapView.showAnnotations(stationsArray, animated: true)
    }
}
