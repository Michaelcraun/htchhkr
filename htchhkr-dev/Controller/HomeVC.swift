
//
//  ViewController.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
//import RevealingSplashView
import Firebase

class HomeVC: UIViewController, MKMapViewDelegate, Alertable {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var actionButton: RoundedShadowButton!
    @IBOutlet var centerMapButton: UIButton!
    @IBOutlet var destinationField: UITextField!
    @IBOutlet var destinationCircle: CircleView!
    var tableView = UITableView()
    
    var delegate: CenterVCDelegate?
    var manager = CLLocationManager()
    var regionRadius: CLLocationDistance = 1000
    var matchingItems = [MKMapItem]()
    var currentUserID = FIRAuth.auth()?.currentUser?.uid
    var selectedPlacemark: MKPlacemark? = nil
    var isMapCenteredOnUser = true
    var route: MKRoute!
    
//    let revealingSplashView = RevealingSplashView(iconImage: #imageLiteral(resourceName: "launchScreenIcon"), iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        manager.delegate = self
        destinationField.delegate = self
        manager.requestAlwaysAuthorization()
//        manager.requestWhenInUseAuthorization()
        checkLocationAuthStatus()
        centerMapOnUserLocation()
        
        DataService.instance.REF_DRIVERS.observe(.value, with: { (snapshot) in
            self.loadDrvierAnnotationsFromFB()
        })
        
//        self.view.addSubview(revealingSplashView)
//        revealingSplashView.animationType = SplashAnimationType.heartBeat
//        revealingSplashView.startAnimation()
//        revealingSplashView.heartAttack = true
        
        UpdateService.instance.observeTrips { (tripDict) in
            if let tripDict = tripDict {
                let pickupCoordinate = tripDict["pickupCoordinate"] as! NSArray
                let tripKey = tripDict["passengerKey"] as! String
                let tripStatus = tripDict["tripIsAccepted"] as! Bool
                if tripStatus == false {
                    DataService.instance.driverIsAvailable(key: self.currentUserID!, handler: { (available) in
                        if let available = available {
                            if available {
                                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                let pickupVC = storyboard.instantiateViewController(withIdentifier: "PickUpVC") as? PickUpVC
                                self.present(pickupVC!, animated: true, completion: nil)
                                pickupVC?.initData(coordinate: CLLocationCoordinate2D(latitude: pickupCoordinate[0] as! CLLocationDegrees,
                                                                                     longitude: pickupCoordinate[1] as! CLLocationDegrees),
                                                  passengerKey: tripKey)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.locationServicesEnabled() {
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.startUpdatingLocation()
            centerMapOnUserLocation()
        } else {
            manager.requestAlwaysAuthorization()
//            manager.requestWhenInUseAuthorization()
        }
    }
    
    func loadDrvierAnnotationsFromFB() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("userIsDriver") {
                        if driver.hasChild("coordinate") {
                            if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {
                                if let driverDict = driver.value as? Dictionary<String,AnyObject> {
                                    let coordinateArray = driverDict["coordinate"] as! NSArray
                                    let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees,
                                                                                  longitude: coordinateArray[1] as! CLLocationDegrees)
                                    let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)
                                    var driverIsVisible: Bool {
                                        return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                            if let driverAnnotation = annotation as? DriverAnnotation {
                                                if driverAnnotation.key == driver.key {
                                                    driverAnnotation.update(annotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                                                    return true
                                                }
                                            }
                                            return false
                                        })
                                    }
                                    
                                    if !driverIsVisible {
                                        self.mapView.addAnnotation(annotation)
                                    }
                                }
                            } else {
                                for annotation in self.mapView.annotations {
                                    if annotation.isKind(of: DriverAnnotation.self) {
                                        if let annotation = annotation as? DriverAnnotation {
                                            if annotation.key == driver.key {
                                                self.mapView.removeAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func centerMapOnUserLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = true
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        UpdateService.instance.updateTripsWithCoordinatesUponRequest()
        actionButton.animateButton(shouldLoad: true, withMessage: nil)
        
        view.endEditing(true)
        destinationField.isUserInteractionEnabled = false
    }
    
    @IBAction func menuButtonWasPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for user in userSnapshot {
                    if user.key == self.currentUserID! {
                        if user.hasChild("tripCoordinate") {
                            self.zoom(toFitAnnotationsFromMapView: self.mapView)
                        } else {
                            self.isMapCenteredOnUser = true
                        }
                    }
                }
            }
        })
    }
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        UpdateService.instance.updateUserLocation(withCoordinate: (locations.last?.coordinate)!)
        UpdateService.instance.updateDriverLocation(withCoordinate: (locations.last?.coordinate)!)
        
        if isMapCenteredOnUser { centerMapOnUserLocation() }
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = destinationField.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                self.showAlert("There was an unexpected error. Please try again.")
            } else if response?.mapItems.count == 0 {
                self.showAlert("There were no results matching your search. Please try again.")
            } else {
                for mapItem in response!.mapItems {
                    self.matchingItems.append(mapItem)
                    self.tableView.reloadData()
                    self.shouldPresentLoadingView(false)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRenderer = MKPolylineRenderer(overlay: route.polyline)
        lineRenderer.strokeColor = UIColor(red: 216/255, green: 71/255, blue: 30/255, alpha: 0.75)
        lineRenderer.lineWidth = 3
        zoom(toFitAnnotationsFromMapView: mapView)
        return lineRenderer
    }
    
    func dropPinFor(_ placemark: MKPlacemark) {
        selectedPlacemark = placemark
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func searchMapKitForResultsWithPolyLine(forMapItem mapItem: MKMapItem) {
        let request = MKDirectionsRequest()
        request.source = .forCurrentLocation()
        request.destination = mapItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let response = response else {
                self.showAlert("There was an unexpected error. Please try again.")
                return
            }
            self.route = response.routes[0]
            self.mapView.add(self.route.polyline)
            self.shouldPresentLoadingView(false)
        }
    }
    
    func zoom(toFitAnnotationsFromMapView mapView: MKMapView) {
        if mapView.annotations.count == 0 { return }
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in mapView.annotations {
            if !annotation.isKind(of: DriverAnnotation.self) {
                topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
            }
        }
        
        let latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5
        let longitude = topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let latitudeDelta = fabs((topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0)
        let longitudeDelta = fabs((bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        var region = MKCoordinateRegion(center: center, span: span)
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
}

extension HomeVC {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = #imageLiteral(resourceName: "driverAnnotation")
            return view
        } else if let annotation = annotation as? PassengerAnnotation {
            let identifier = "passenger"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = #imageLiteral(resourceName: "currentLocationAnnotation")
            return view
        } else if let annotation = annotation as? MKPointAnnotation {
            let identifier = "destination"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "destinationAnnotation")
            return annotationView
        }
        return nil
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.debugDescription)
        if textField == destinationField {
            isMapCenteredOnUser = false
            tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - 170)
            tableView.layer.cornerRadius = 5
            tableView.rowHeight = 60
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tag = 3030
            
            view.addSubview(tableView)
            animateTableView(shouldShow: true)
            UIView.animate(withDuration: 0.2, animations: {
                self.destinationCircle.backgroundColor = UIColor.red
                self.destinationCircle.borderColor = UIColor.init(red: 199 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
            })
            print("tableView.frame: \(tableView.frame)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == destinationField {
            shouldPresentLoadingView(true)
            performSearch()
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == destinationField {
            if textField.text == "" {
                UIView.animate(withDuration: 0.2, animations: {
                    self.destinationCircle.backgroundColor = UIColor.lightGray
                    self.destinationCircle.borderColor = UIColor.darkGray
                })
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()
        
        DataService.instance.REF_USERS.child(currentUserID!).child("tripCoordinate").removeValue()
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            } else if annotation.isKind(of: PassengerAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        centerMapOnUserLocation()
        return true
    }
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
            }, completion: { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 3030 {
                        subview.removeFromSuperview()
                    }
                }
            })
        }
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldPresentLoadingView(true)
        let passengerCoordinate = manager.location?.coordinate
        let passengerAnnotation = PassengerAnnotation(coordinate: passengerCoordinate!, key: currentUserID!)
        mapView.addAnnotation(passengerAnnotation)
        destinationField.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        let selectedResult = matchingItems[indexPath.row]
        DataService.instance.REF_USERS.child(currentUserID!).updateChildValues(["tripCoordinate" : [selectedResult.placemark.coordinate.latitude,
                                                                                                    selectedResult.placemark.coordinate.longitude]])
        dropPinFor(selectedResult.placemark)
        searchMapKitForResultsWithPolyLine(forMapItem: selectedResult)
        animateTableView(shouldShow: false)
        destinationField.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if destinationField.text == "" {
            animateTableView(shouldShow: false)
        }
    }
}
