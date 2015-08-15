//
//  GetLocationViewController.swift
//  HWLocation
//
//  Created by Zun Wang on 8/7/15.
//  Copyright (c) 2015 ZW. All rights reserved.
//

import UIKit
import CoreLocation

class GetLocationViewController: UIViewController, CLLocationManagerDelegate {
  
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagLocationButton: UIButton!
  @IBOutlet weak var getMyLocationButton: UIButton!
  
  let locationManager = CLLocationManager()
  let geocoder = CLGeocoder()
  
  var location: CLLocation?
  var performingReverseGeocoding = false
  var placemark: CLPlacemark?
  var updatingLocation = false
  var lastGeocodingError: NSError?
  var lastLocationError: NSError?
  var timer:NSTimer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    configureGetButton()
  }
  
  @IBAction func didTapTagLocationButton(sender: UIButton) {
  }
  

  @IBAction func didTapGetMyLocationButton(sender: UIButton) {
    let authStatus = CLLocationManager.authorizationStatus()

    if authStatus == .NotDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      placemark = nil
      lastGeocodingError = nil
      startLocationManager()
    }

    updateLabels()
    configureGetButton()
  }
  
  // MARK: - Util function
  
  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.5f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.5f", location.coordinate.longitude)
      tagLocationButton.hidden = false
      messageLabel.text = ""

      if let placemark = placemark {
        addressLabel.text = stringFromPlacemark(placemark)
      } else if performingReverseGeocoding {
        addressLabel.text = "Searching for Address..."
      } else if lastGeocodingError != nil {
        addressLabel.text = "Error Finding Address"
      } else {
        addressLabel.text = "No Address Found"
      }
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagLocationButton.hidden = true
      
      if lastLocationError != nil {
        messageLabel.text = "Error Getting Location"
      } else if !CLLocationManager.locationServicesEnabled() {
        messageLabel.text = "Location Services Disabled"
      } else if updatingLocation {
        messageLabel.text = "Searching..."
      } else {
        messageLabel.text = "Tap 'Get My Location' to Start"
      }
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true
      timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
    }
  }
  
  func stopLocationManager() {
    if updatingLocation {
      if let timer = timer {
        timer.invalidate()
      }

      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }
  
  func configureGetButton() {
    getMyLocationButton.setTitle(updatingLocation ? "Stop" : "Get My Location", forState: .Normal)
  }
  
  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    return
      "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" +
      "\(placemark.locality) \(placemark.administrativeArea) " +
      "\(placemark.postalCode)"
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    let newLocation = locations.last as! CLLocation
    println("didUpdateLocations \(newLocation)")
    
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    var distance = CLLocationDistance(DBL_MAX)
    if let location = location {
      distance = newLocation.distanceFromLocation(location)
    }

    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      location = newLocation
      
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        stopLocationManager()
        configureGetButton()

        if distance > 0 {
          performingReverseGeocoding = false
        }
      }
      
      updateLabels()
      
      if !performingReverseGeocoding {
        performingReverseGeocoding = true
        
        unowned let weakSelf = self
        geocoder.reverseGeocodeLocation(location, completionHandler: {
          placemarks, error in
          weakSelf.lastGeocodingError = error
          if error == nil && !placemarks.isEmpty {
            weakSelf.placemark = placemarks.last as? CLPlacemark
          } else {
            weakSelf.placemark = nil
          }
          
          self.performingReverseGeocoding = false
          self.updateLabels()
        })
      }
    } else if distance < 1.0 {
      let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
      if timeInterval > 10 {
        stopLocationManager()
        updateLabels()
        configureGetButton()
      }
    }
  }
  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    lastLocationError = error
    
    stopLocationManager()
    updateLabels()
    configureGetButton()
  }
  
  func didTimeOut() {
    if location == nil {
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      stopLocationManager()
      updateLabels()
      configureGetButton()
    }
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "tagLocation" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let tableViewController = navigationController.topViewController as! LocationDetailViewController
      
      tableViewController.latitude = location!.coordinate.latitude
      tableViewController.longitude = location!.coordinate.longitude
      tableViewController.address = addressLabel.text
      
      
//      let navigationController = segue.destinationViewController as! UINavigationController
//      let controller = navigationController.topViewController as! LocationDetailsViewController
//      
//      controller.coordinate = location!.coordinate
//      controller.placemark = placemark
    }
  }
}
