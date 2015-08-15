//
//  Location.swift
//  HWLocation
//
//  Created by Zun Wang on 8/8/15.
//  Copyright (c) 2015 ZW. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Location: NSObject, MKAnnotation {
  
  var latitude: Double
  var longitude: Double
  var address: String
  var locationDescription: String
  var date: NSDate
//  var placemark: CLPlacemark?
  
  init(latitude: Double, longitude: Double, address: String, locationDescription: String, date: NSDate) {
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.locationDescription = locationDescription
    self.date = date
//    self.placemark = placemark
    super.init()
  }
  
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  var title: String {
    return locationDescription
  }
  
  var subtitle: String {
    return "hehe"
  }
}
