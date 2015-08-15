//
//  LocationDetailViewController.swift
//  HWLocation
//
//  Created by Zun Wang on 8/8/15.
//  Copyright (c) 2015 ZW. All rights reserved.
//

import UIKit

class LocationDetailViewController: UITableViewController {
   
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  var locationDescription = ""
  var latitude: Double?
  var longitude: Double?
  var address: String?
  var date: NSDate?
  
  let dateFormatter = NSDateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    descriptionTextView.text = locationDescription
    descriptionTextView.delegate = self
    if let lat = latitude {
      latitudeLabel.text = String(format: "%.5f", arguments: [lat])
    }
    if let lon = longitude {
      longitudeLabel.text = String(format: "%.5f", arguments: [lon])
    }
    addressLabel.text = (address != nil) ? address : "No address"
    
    date = NSDate()
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateLabel.text = dateFormatter.stringFromDate(date!)
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "didTapCancelButton")
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "didTapDoneButton")
  }
  
  func didTapCancelButton() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func didTapDoneButton() {
    let newLocation = Location(
      latitude: latitude!,
      longitude: longitude!,
      address: address!,
      locationDescription: locationDescription,
      date: date!)
    taggedLocations.append(newLocation)
    
    let alertVC = UIAlertController(title: "Done!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
    self.presentViewController(alertVC, animated: true, completion: {
      [unowned self] in
      let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC)))
      dispatch_after(when, dispatch_get_main_queue(), {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
      })
    })
  }
  
  func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.locationInView(tableView)
    let indexPath = tableView.indexPathForRowAtPoint(point)
    if indexPath != nil &&
      indexPath!.section == 0 &&
      indexPath!.row == 0 {
      return
    }
    descriptionTextView.resignFirstResponder()
  }
}

extension LocationDetailViewController: UITextViewDelegate {
  func textViewDidEndEditing(textView: UITextView) {
    locationDescription = textView.text
  }
}
