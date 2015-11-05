//
//  MapViewController.swift
//  Bike Buddy
//
//  Created by Tom Arra on 5/20/15.
//  Copyright (c) 2015 Cloudgate Studios. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD

class MapViewController: UIViewController {
    //MARK: - Class Variables
    
    private var tappedStation: Station!
    
    //MARK: - View Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBarItem: UINavigationItem!
    
    //MARK: - View Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMapAnnotations", name: NOTIFICATION_CENTER_STATIONS_LIST_UPDATED, object: nil)
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
    
    func showLoadingPopover() {
        SVProgressHUD.showWithStatus(NSLocalizedString("MapLoadingPopupMessage", comment: ""))
    }
    
    func refreshMapAnnotations() {
        self.loadAnnotationsOnMapView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SHOW_STATION_DETAIL_FROM_MAP_SEGUE_IDENTIFIER) {
            let vc = (segue.destinationViewController as! StationDetailViewController)
            vc.stationObject = self.tappedStation
            
            self.tappedStation = nil
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
        
        self.performSegueWithIdentifier(SHOW_STATION_DETAIL_FROM_MAP_SEGUE_IDENTIFIER, sender: self)
    }
    
    /**
    Take the current Stations.list and load the needed annotations on the map
    */
    private func loadAnnotationsOnMapView() {
        SVProgressHUD.dismiss()
        
        if let pins = mapView?.annotations {
            mapView.removeAnnotations(pins)
        }

        mapView?.addAnnotations(Stations.sharedInstance.list)
        mapView?.showAnnotations(Stations.sharedInstance.list, animated: true)
    }
}
