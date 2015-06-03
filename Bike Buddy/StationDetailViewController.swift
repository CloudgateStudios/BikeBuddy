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
    
    //MARK: - View Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.addAnnotation(stationObject)
        mapView.showAnnotations([stationObject], animated: false)
        stationNameLabel.text = stationObject.stationName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Map View
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "StationDetailMapPinID")
        annotationView.animatesDrop = false
        
        return annotationView
    }
}
