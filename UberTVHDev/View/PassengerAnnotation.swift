//
//  PassengerAnnotation.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/6/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import Foundation
import MapKit

class PassengerAnnotation: NSObject, MKAnnotation{
  dynamic var coordinate: CLLocationCoordinate2D
  var key: String
  
  init(coordinate: CLLocationCoordinate2D, key: String){
    self.coordinate = coordinate
    self.key = key
    super.init()
  }
}
