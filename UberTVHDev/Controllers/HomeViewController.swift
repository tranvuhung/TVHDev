//
//  ViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/27/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RevealingSplashView

class HomeViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var requestRideBtn: RoundedButton!
  @IBOutlet weak var mapView: MKMapView!
  var delegate: CenterVCDelegate?
  
  var locationManager: CLLocationManager?
  var regionRadius: CLLocationDistance = 1000
  
  let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "appicon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1)
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    
    checkLocationAuthStatus()
    
    mapView.delegate = self
    
    centerMapUserLocation()
    
    self.view.addSubview(revealingSplashView)
    revealingSplashView.animationType = SplashAnimationType.heartBeat
    revealingSplashView.startAnimation()
    revealingSplashView.heartAttack = true
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  //MARK: - Check location
  func checkLocationAuthStatus(){
    if CLLocationManager.authorizationStatus() == .authorizedAlways{
      locationManager?.startUpdatingLocation()
    } else {
      locationManager?.requestAlwaysAuthorization()
    }
  }
  
  func centerMapUserLocation(){
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  //MARK: - Animate Action Request Ride
  @IBAction func requestRideAction(_ sender: Any) {
    requestRideBtn.animateButton(shouldLoad: true, withMessage: nil)
  }
  
  //MARK: - Open Left side controller
  @IBAction func openLeftMenuPress(_ sender: Any) {
    delegate?.toggoleLeftPanel()
  }
  
  //MARK: - Center user location
  @IBAction func centerUserLocationAction(_ sender: Any) {
    centerMapUserLocation()
  }
  
  //MARK: Update location user/driver
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    UpdateServices.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
    UpdateServices.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let annotation = annotation as? DriverAnnotation{
      let identifer = "driver"
      var view: MKAnnotationView
      view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifer)
      view.image = UIImage(named: "driverAnnotation")
      return view
    }
    return nil
  }
}

extension HomeViewController: CLLocationManagerDelegate{
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways{
      mapView.showsUserLocation = true
      mapView.userTrackingMode = .follow
    }
  }
}
