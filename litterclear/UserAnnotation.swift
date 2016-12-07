//
//  UserAnnotation.swift
//  litterclear
//
//  Created by Neha Parmar on 12/6/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var imgName: String
    let address: String
    let size: String
    var title: String?
    
    init(title: String, address: String, size: String,coordinate: CLLocationCoordinate2D) {
        print("Just created user annotation.")
        self.title = title
        self.coordinate = coordinate
        self.imgName = "red_slant"
        self.address = address
        self.size = size
        
    }
}
