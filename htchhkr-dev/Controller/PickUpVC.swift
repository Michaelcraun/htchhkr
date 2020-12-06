//
//  PickUpVC.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/6/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import MapKit

class PickUpVC: UIViewController {

    @IBOutlet var acceptTripButton: RoundedShadowButton!
    @IBOutlet var mapView: RoundMapView!
    
    var regionRadius: CLLocationDistance = 1000
    var pin: MKPlacemark? = nil
    var pickupCoordinate: CLLocationCoordinate2D!
    var passengerKey: String!
    var locationPlacemare: MKPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationPlacemare = MKPlacemark(coordinate: pickupCoordinate)
        dropPinFor(placemark: locationPlacemare)
        centerMapOnLocation(location: locationPlacemare.location!)
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptTripButtonPressed(_ sender: Any) {
        
    }
    
    func initData(coordinate: CLLocationCoordinate2D, passengerKey: String) {
        self.pickupCoordinate = coordinate
        self.passengerKey = passengerKey
    }
}

extension PickUpVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pickUpPoint"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = #imageLiteral(resourceName: "destinationAnnotation")
        return annotationView
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func dropPinFor(placemark: MKPlacemark) {
        pin = placemark
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
}
