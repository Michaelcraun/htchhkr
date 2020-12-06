//
//  PassengerAnnotation.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/4/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import MapKit

class PassengerAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
}
