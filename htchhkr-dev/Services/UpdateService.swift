//
//  UpdateService.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/4/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Firebase

class UpdateService {
    static let instance = UpdateService()
    
    func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for user in userSnapshot {
                    if user.key == FIRAuth.auth()?.currentUser?.uid {
                        DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate" : [coordinate.latitude, coordinate.longitude]])
                    }
                }
            }
        })
    }
    
    func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let driverSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for driver in driverSnapshot {
                    if driver.key == FIRAuth.auth()?.currentUser?.uid {
                        if driver.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool == true {
                            DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate" : [coordinate.latitude, coordinate.longitude]])
                        }
                    }
                }
            }
        })
    }
    
    func updateTripsWithCoordinatesUponRequest() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for user in userSnapshot {
                    if user.key == FIRAuth.auth()?.currentUser?.uid {
                        if !user.hasChild("userIsDriver") {
                            if let userDict = user.value as? Dictionary<String,AnyObject> {
                                let pickupArray = userDict["coordinate"] as! NSArray
                                let destinationArray = userDict["tripCoordinate"] as! NSArray
                                
                                DataService.instance.REF_TRIPS.child(user.key).updateChildValues([
                                    "pickupCoordinate" : [pickupArray[0], pickupArray[1]],
                                    "destinationCoordinate" : [destinationArray[0], destinationArray[1]],
                                    "passengerKey" : user.key,
                                    "tripIsAccepted" : false
                                    ])
                            }
                        }
                    }
                }
            }
        })
    }
    
    func observeTrips(handler: @escaping (_ coordinateDict: Dictionary<String,AnyObject>?) -> Void) {
        DataService.instance.REF_TRIPS.observe(.value, with: { (snapshot) in
            if let tripSnapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for trip in tripSnapshot {
                    if trip.hasChild("passengerKey") && trip.hasChild("tripIsAccepted") {
                        if let tripDict = trip.value as? Dictionary<String,AnyObject> {
                            handler(tripDict)
                        }
                    }
                }
            }
        })
    }
}
