//
//  MapViewController.swift
//  HWLocation
//
//  Created by Zun Wang on 8/8/15.
//  Copyright (c) 2015 ZW. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
   
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func didTapLocationsButton(sender: UIBarButtonItem) {
    showLocations()
  }
  
  @IBAction func didTapUserButton(sender: UIBarButtonItem) {
    showCurrentLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    mapView.showsUserLocation = true
    showLocations()
    updateAnnotations()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    showLocations()
    updateAnnotations()
  }
  
  func showCurrentLocation() {
    let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }
  
  func showLocations() {
    switch taggedLocations.count {
    case 0:
      showCurrentLocation()
      
    case 1:
      let region = MKCoordinateRegionMakeWithDistance(taggedLocations[0].coordinate, 1000, 1000)
      mapView.setRegion(mapView.regionThatFits(region), animated: true)
      
    default:
      mapView.showAnnotations(taggedLocations, animated: true)
    }
  }
  
  func updateAnnotations() {
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotations(taggedLocations)
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    if annotation is Location {
      let identifier = "Location"
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        annotationView.enabled = true
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        annotationView.pinColor = MKPinAnnotationColor.Purple
        
//        let rightButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
//        rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents:UIControlEvents.TouchUpInside)
//        annotationView.rightCalloutAccessoryView = rightButton
      } else {
        annotationView.annotation = annotation
      }
      
//      let button = annotationView.rightCalloutAccessoryView as! UIButton
//      if let index = find(taggedLoactions, annotation as! Location) {
//        button.tag = index
//      }
      
      return annotationView
    }
    
    return nil
  }
}
