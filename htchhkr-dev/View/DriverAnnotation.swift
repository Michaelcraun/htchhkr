//
//  DriverAnnotation.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/4/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import MapKit

class s: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var key: String
    
    init(coordinate: CLLocationCoordinate2D, withKey key: String) {
        self.coordinate = coordinate
        self.key = key
        super.init()
    }
    
//    func update(annotationPosition annotation: DriverAnnotation, withCoordinate coordinate: CLLocationCoordinate2D) {
//        var location = self.coordinate
//        location.latitude = coordinate.latitude
//        location.longitude = coordinate.longitude
//        UIView.animate(withDuration: 0.2) {
//            self.coordinate = location
//        }
//    }
}
