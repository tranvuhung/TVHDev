//
//  PickupViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/9/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import MapKit

class PickupViewController: UIViewController {
  
  @IBOutlet weak var pickupMapView: RoundMapView!
  
  var regionRadius: CLLocationDistance = 2000
  var pin: MKPlacemark? = nil
  
  var pickupCoordinate: CLLocationCoordinate2D!
  var passengerkey: String!
  
  var locationPlaceMark: MKPlacemark!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pickupMapView.delegate = self
    
    locationPlaceMark = MKPlacemark(coordinate: pickupCoordinate)
    dropPinFor(placeMark: locationPlaceMark)
    centerMapOnLocation(location: locationPlaceMark.location!)
  }
  
  func initData(coordinate: CLLocationCoordinate2D, passengerKey: String){
    self.pickupCoordinate = coordinate
    self.passengerkey = passengerKey
  }
  
  @IBAction func acceptTripBtnPressed(_ sender: Any) {
    
  }
  
  @IBAction func closeBtnPressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension PickupViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "pickupPoint"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    if annotationView == nil{
      annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
    } else {
      annotationView?.annotation = annotation
    }
    annotationView?.image = UIImage(named: "destinationAnnotation")
    return annotationView
  }
  
  func centerMapOnLocation(location: CLLocation){
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
    pickupMapView.setRegion(coordinateRegion, animated: true)
  }
  
  func dropPinFor(placeMark: MKPlacemark){
    pin = placeMark
    for annotaion in pickupMapView.annotations {
      pickupMapView.removeAnnotation(annotaion)
    }
    let annotation = MKPointAnnotation()
    annotation.coordinate = placeMark.coordinate
    
    pickupMapView.addAnnotation(annotation)
  }
}
