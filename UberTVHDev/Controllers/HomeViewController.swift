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
import Firebase
import RevealingSplashView

class HomeViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var requestRideBtn: RoundedButton!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var centerMapBtn: UIButton!
  @IBOutlet weak var destinationTexfield: UITextField!
  @IBOutlet weak var destinationCircleView: CircleView!
  
  let tableView = UITableView()
  
  var delegate: CenterVCDelegate?
  
  var locationManager: CLLocationManager?
  var regionRadius: CLLocationDistance = 1000
  
  let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "appicon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)

  //MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1)
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    
    checkLocationAuthStatus()
    
    mapView.delegate = self
    destinationTexfield.delegate = self
    
    centerMapUserLocation()
    
    DataService.instance.REF_DRIVERS.observe(.value) { (dataSnapshot) in
      self.loadDriverLocationFromFB()
    }
    
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
  
  //MARK: - load instance of driver
  func loadDriverLocationFromFB(){
    DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
      guard let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {return}
      
      for driver in driverSnapshot{
        guard driver.hasChild("coordinate") else {return}
        
        guard driver.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true else {
          for annotation in self.mapView.annotations{
            if annotation.isKind(of: DriverAnnotation.self){
              if let annotation = annotation as? DriverAnnotation{
                if annotation.key == driver.key{
                  self.mapView.removeAnnotation(annotation)
                }
              }
            }
          }
          return
        }
        guard let driverDic = driver.value as? Dictionary<String, AnyObject> else {return}
        let coordinateArray = driverDic["coordinate"] as! NSArray
        let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
        let annotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driver.key)
        
        var driverIsVisible: Bool{
          return self.mapView.annotations.contains(where: { (annotation) -> Bool in
            if let driverAnnotation = annotation as? DriverAnnotation {
              if driverAnnotation.key == driver.key {
                driverAnnotation.update(annotationPosition: driverAnnotation, withCoordinate: driverCoordinate)
                return true
              }
            }
            return false
          })
        }
        
        if !driverIsVisible{
          self.mapView.addAnnotation(annotation)
        }
      }
      
    }
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
    centerMapBtn.fadeTo(alpha: 0.0, withDuration: 0.2)
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
  
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    centerMapBtn.fadeTo(alpha: 1.0, withDuration: 0.2)
  }
}

extension HomeViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == destinationTexfield {
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
      tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: 200)
      tableView.rowHeight = 60
      tableView.layer.cornerRadius = 5.0
      tableView.tag = 18
      
      tableView.delegate = self
      tableView.dataSource = self
      
      view.addSubview(tableView)
      animateTableView(shouldShow: true)
      
      UIView.animate(withDuration: 0.2) {
        self.destinationCircleView.backgroundColor = UIColor.red
        self.destinationCircleView.borderColor = UIColor.init(red: 199/255, green: 0/255, blue: 0/255, alpha: 1.0)
      }
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == destinationTexfield{
      if destinationTexfield.text == "" {
        UIView.animate(withDuration: 0.2) {
          self.destinationCircleView.backgroundColor = UIColor.lightGray
          self.destinationCircleView.borderColor = UIColor.darkGray
        }
      }
    }
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    centerMapUserLocation()
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == destinationTexfield {
      //performSearch()
      view.endEditing(true)
    }
    return true
  }
  
  func animateTableView(shouldShow: Bool){
    if shouldShow{
      UIView.animate(withDuration: 0.2) {
        self.tableView.frame = CGRect(x: 20, y: 185, width: self.view.frame.width - 40, height: self.view.frame.height - 200)
      }
    }else {
      UIView.animate(withDuration: 0.2, animations: {
        self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: 200)
      }) { (finished) in
        for subview in self.view.subviews{
          if subview.tag == 18{
            subview.removeFromSuperview()
          }
        }
      }
    }
  }
  
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    animateTableView(shouldShow: false)
    print("Selected!")
  }
}
