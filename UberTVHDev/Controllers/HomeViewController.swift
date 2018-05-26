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

enum AnnotationType {
  case pickUp
  case destination
  case driver
}

enum ButtonAction {
  case requestRide
  case getDirectionsToPassenger
  case getDirectionsToDestination
  case startTrip
  case endTrip
}

class HomeViewController: UIViewController, MKMapViewDelegate, Alertable {
  
  @IBOutlet weak var requestRideBtn: RoundedButton!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var centerMapBtn: UIButton!
  @IBOutlet weak var destinationTexfield: UITextField!
  @IBOutlet weak var destinationCircleView: CircleView!
  @IBOutlet weak var btnCancel: UIButton!
  
  let tableView = UITableView()
  
  var delegateExpanded: CenterVCDelegate?
  
  var locationManager: CLLocationManager?
  var regionRadius: CLLocationDistance = 1000
  
  let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "appicon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)
  
  var matchingItems: [MKMapItem] = [MKMapItem]()
  
  let currentUserId = Auth.auth().currentUser?.uid
  
  var selectedItemPlacemark: MKPlacemark? = nil
  
  var router: MKRoute!
  
  var actionForButton: ButtonAction = .requestRide

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
    
    btnCancel.alpha = 0.0
    
    centerMapUserLocation()
    
    DataService.instance.REF_DRIVERS.observe(.value) { (dataSnapshot) in
      self.loadDriverLocationFromFB()
      
      DataService.instance.passengerIsOnTrip(passengerKey: Auth.auth().currentUser!.uid, handler: { (isOnTrip, driverKey, tripKey) in
        if isOnTrip == true {
          self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: true, withKey: driverKey)
        }
      })
    }
    
    self.view.addSubview(revealingSplashView)
    revealingSplashView.animationType = SplashAnimationType.heartBeat
    revealingSplashView.startAnimation()
    
    UpdateServices.instance.observeTrips { (tripDict) in
      if let tripDict = tripDict {
        let pickupCoordinateArray = tripDict["pickupCoordinate"] as! NSArray
        let tripkey = tripDict["passengerKey"] as! String
        let acceptanceStatus = tripDict["tripIsAccepted"] as! Bool
        
        if acceptanceStatus == false {
          DataService.instance.driverIsAvailable(key: Auth.auth().currentUser!.uid, handler: { (availbale) in
            if let availbale = availbale {
              if availbale == true {
                let storyboad = UIStoryboard(name: "Main", bundle: Bundle.main)
                let pickupVC = storyboad.instantiateViewController(withIdentifier: "pickupVC") as? PickupViewController
                pickupVC?.initData(coordinate: CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees), passengerKey: tripkey)
                self.present(pickupVC!, animated: true, completion: nil)
              }
            }
          })
        }
      }
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    DataService.instance.userIsDriver(userKey: Auth.auth().currentUser!.uid) { (status) in
      if status == true {
        self.buttonForDriver(areHidden: true)
      }
    }
    
    DataService.instance.REF_TRIPS.observe(.childRemoved) { (removedTripSnapshot) in
      let removedTrip = removedTripSnapshot.value as? [String: AnyObject]
      if removedTrip?["driverKey"] != nil {
        DataService.instance.REF_DRIVERS.child(removedTrip?["driverKey"] as! String).updateChildValues(["driverIsOnTrip": false])
      }
      
      DataService.instance.userIsDriver(userKey: Auth.auth().currentUser!.uid, handler: { (isDriver) in
        if isDriver == true {
          self.removeOverlayAndAnnotations(forDrivers: false, forPassengers: true)
        } else {
          self.btnCancel.fadeTo(alpha: 0.0, withDuration: 0.2)
          self.requestRideBtn.animateButton(shouldLoad: false, withMessage: "REQUSET RIDE")
          
          self.destinationTexfield.isUserInteractionEnabled = true
          self.destinationTexfield.text = ""
          
          self.removeOverlayAndAnnotations(forDrivers: false, forPassengers: true)
          self.centerMapUserLocation()
        }
      })
      
    }
    
    DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
      if isOnTrip == true {
        DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
          if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
            for trip in tripSnapshot {
              if trip.childSnapshot(forPath: "driverKey").value as? String == Auth.auth().currentUser!.uid {
                let pickupCoordinateArray = trip.childSnapshot(forPath: "pickupCoordinate").value as! NSArray
                let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
                let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
                
                self.dropPinFor(placemark: pickupPlacemark)
                self.searchResultsWithPolyline(originMapItem: nil, destinationMapItem: MKMapItem(placemark: pickupPlacemark))
                self.setCustomRegion(forAnnotationType: .pickUp , withCoordinate: pickupCoordinate)
                
                self.actionForButton = .getDirectionsToPassenger
                self.requestRideBtn.setTitle("GET DIRECTIONS", for: .normal)
                
                self.buttonForDriver(areHidden: false)
              }
            }
          }
        })
      }
    }
    /*
    DataService.instance.driverIsAvailable(key: Auth.auth().currentUser!.uid) { (status) in
      if status == false {
        
      }
    }*/
    
    connectUserAndDriverForTrip()
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
  
  func buttonForDriver(areHidden: Bool){
    if areHidden {
      self.requestRideBtn.fadeTo(alpha: 0.0, withDuration: 0.2)
      self.btnCancel.fadeTo(alpha: 0.0, withDuration: 0.2)
      self.centerMapBtn.fadeTo(alpha: 0.0, withDuration: 0.2)
      self.requestRideBtn.isHidden = true
      self.btnCancel.isHidden = true
      self.centerMapBtn.isHidden = true
    } else {
      self.requestRideBtn.fadeTo(alpha: 1.0, withDuration: 0.2)
      self.btnCancel.fadeTo(alpha: 1.0, withDuration: 0.2)
      self.centerMapBtn.fadeTo(alpha: 1.0, withDuration: 0.2)
      self.requestRideBtn.isHidden = false
      self.btnCancel.isHidden = false
      self.centerMapBtn.isHidden = false
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
    
    revealingSplashView.heartAttack = true
  }
  
  //MARK: - Animate Action Request Ride
  @IBAction func requestRideAction(_ sender: Any) {
    buttonSelector(forAction: actionForButton)
  }
  
  //MARK: - Open Left side controller
  @IBAction func openLeftMenuPress(_ sender: Any) {
    delegateExpanded?.toggoleLeftPanel()
  }
  
  func buttonSelector(forAction action: ButtonAction){
    switch action {
    case .requestRide:
      if destinationTexfield.text != "" {
        UpdateServices.instance.updateTripWithCoordinatesUponRequest()
        requestRideBtn.animateButton(shouldLoad: true, withMessage: nil)
        btnCancel.fadeTo(alpha: 1.0, withDuration: 0.2)
        self.view.endEditing(true)
        destinationTexfield.isUserInteractionEnabled = false
      }
    case .getDirectionsToPassenger:
      DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
        if isOnTrip == true {
          DataService.instance.REF_TRIPS.child(tripKey!).observe(.value, with: { (tripSnapshot) in
            let tripDic = tripSnapshot.value as? Dictionary<String, AnyObject>
            
            let pickupCoordinateArray = tripDic!["pickupCoordinate"] as! NSArray
            let pickupCoordinate = CLLocationCoordinate2DMake(pickupCoordinateArray[0] as! CLLocationDegrees, pickupCoordinateArray[1] as! CLLocationDegrees)
            let pickupMapItem = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate))
            pickupMapItem.name = "Passenger Pickup Point"
            pickupMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
          })
        }
      }
    case .getDirectionsToDestination:
      print("Got directions to destination")
    case .startTrip:
      DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
        if isOnTrip == true {
          self.removeOverlayAndAnnotations(forDrivers: false, forPassengers: false)
          
          DataService.instance.REF_TRIPS.child(tripKey!).updateChildValues(["tripIsInProgress" : true])
          
          DataService.instance.REF_TRIPS.child(tripKey!).child("destinationCoordinate").observeSingleEvent(of: .value, with: { (coordinateSnapshot) in
            let destinationCoordinateArray = coordinateSnapshot.value as! NSArray
            let destinationCoordinate = CLLocationCoordinate2D(latitude: destinationCoordinateArray[0] as! CLLocationDegrees, longitude: destinationCoordinateArray[1] as! CLLocationDegrees)
            let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
            self.dropPinFor(placemark: destinationPlaceMark)
            self.searchResultsWithPolyline(originMapItem: nil, destinationMapItem: MKMapItem(placemark: destinationPlaceMark))
            self.setCustomRegion(forAnnotationType: .destination, withCoordinate: destinationCoordinate)
            
            self.actionForButton = .getDirectionsToDestination
            self.requestRideBtn.setTitle("GET DIRECTIONS", for: .normal)
          })
        }
      }
    case .endTrip:
      print("End trip")
    }
  }
  
  //MARK: - Center user location
  @IBAction func centerUserLocationAction(_ sender: Any) {
    DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
      if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
        for user in userSnapshot {
          if user.key == Auth.auth().currentUser!.uid {
            if user.hasChild("tripCoordinate") {
              self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: false, withKey: nil)
              self.centerMapBtn.fadeTo(alpha: 0.0, withDuration: 0.2)
            } else {
             self.centerMapUserLocation()
              self.centerMapBtn.fadeTo(alpha: 0.0, withDuration: 0.2)
            }
          }
        }
      }
    }
    
  }
  
  @IBAction func cancelBtnWasPressed(_ sender: Any) {
    DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
      if isOnTrip == true {
        UpdateServices.instance.cancelTrip(withPassenger: tripKey!, forDriver: driverKey!)
      }
    }
    
    DataService.instance.passengerIsOnTrip(passengerKey: Auth.auth().currentUser!.uid) { (isOnTrip, driveKey, tripKey) in
      if isOnTrip == true {
        UpdateServices.instance.cancelTrip(withPassenger: Auth.auth().currentUser!.uid, forDriver: driveKey!)
      } else {
        UpdateServices.instance.cancelTrip(withPassenger: Auth.auth().currentUser!.uid, forDriver: nil)
      }
    }
    
    self.requestRideBtn.isUserInteractionEnabled = true
  }
  
  //MARK: Update location user/driver
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    UpdateServices.instance.updateUserLocation(withCoordinate: userLocation.coordinate)
    UpdateServices.instance.updateDriverLocation(withCoordinate: userLocation.coordinate)
    
    DataService.instance.userIsDriver(userKey: Auth.auth().currentUser!.uid) { (isDriver) in
      if isDriver == true {
        DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid, handler: { (isOnTrip, driverKey, tripKey) in
          if isOnTrip == true {
            self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: true, withKey: driverKey)
          } else {
            self.centerMapUserLocation()
          }
        })
      } else {
        DataService.instance.passengerIsOnTrip(passengerKey: Auth.auth().currentUser!.uid, handler: { (isOnTrip, driverKey, tripKey) in
          if isOnTrip == true {
            self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: true, withKey: driverKey)
          } else {
            self.centerMapUserLocation()
          }
        })
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    if let annotation = annotation as? DriverAnnotation{
      let identifer = "driver"
      var view: MKAnnotationView
      view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifer)
      view.image = UIImage(named: "driverAnnotation")
      return view
    } else if let annotation = annotation as? PassengerAnnotation{
      let identifier = "passenger"
      var view: MKAnnotationView
      view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      view.image = UIImage(named: "currentLocationAnnotation")
      return view
    }else if let anno = annotation as? MKPointAnnotation{
      let identifier = "destination"
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      if annotationView  == nil {
        annotationView = MKAnnotationView(annotation: anno, reuseIdentifier: identifier)
      }else {
        annotationView?.annotation = anno
      }
      annotationView?.image = UIImage(named: "destinationAnnotation")
      return annotationView
    }
    return nil
  }
  
  //MARK: - Search location map items
  func performSearch(){
    matchingItems.removeAll()
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = destinationTexfield.text
    request.region = mapView.region
    
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
      if error != nil{
        self.showAlert("An unexpected error occurred. Please try again.")
        print(error.debugDescription)
      } else if response?.mapItems.count == 0 {
        self.showAlert("No results! Please search again for a different location.")
      } else {
        for mapItems in response!.mapItems{
          self.matchingItems.append(mapItems)
          self.tableView.reloadData()
          self.shouldPresentLoadingView(status: false)
        }
      }
    }
  }
  
  //MARK: - Drop pin location
  func dropPinFor(placemark: MKPlacemark){
    selectedItemPlacemark = placemark
    
    for annotation in mapView.annotations{
      if annotation.isKind(of: MKPointAnnotation.self){
        mapView.removeAnnotation(annotation)
      }
    }
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    mapView.addAnnotation(annotation)
  }
  
  //MARK: Render polyline
  func searchResultsWithPolyline(originMapItem: MKMapItem?, destinationMapItem: MKMapItem){
    let requset = MKDirectionsRequest()
    if originMapItem == nil {
      requset.source = MKMapItem.forCurrentLocation()
    } else {
      requset.source = originMapItem
    }
    requset.destination = destinationMapItem
    requset.transportType = MKDirectionsTransportType.automobile
    
    let direction = MKDirections(request: requset)
    direction.calculate { (response, error) in
      guard let response = response else {
        self.showAlert("An unexpected error occurred. Please try again.")
        print(error.debugDescription)
        return
      }
      self.router = response.routes[0]
      //if self.mapView.overlays.count == 0 {
      self.mapView.add(self.router!.polyline)
      //}
      
      self.zoom(toFitAnnotationsFromMapView: self.mapView, forActiveTripWithDriver: false, withKey: nil)
      
      let delegate = AppDelegate.getAppDelegate()
      delegate.window?.rootViewController?.shouldPresentLoadingView(status: false)
    }
    
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let lineRenderer = MKPolylineRenderer(overlay: self.router.polyline)
    lineRenderer.strokeColor = UIColor(red: 216/255, green: 71/255, blue: 30/255, alpha: 0.75)
    lineRenderer.lineWidth = 3
    
    shouldPresentLoadingView(status: false)
    
    return lineRenderer
  }
  
  //MARK:  Zooming in on mapview
  func zoom(toFitAnnotationsFromMapView mapView: MKMapView, forActiveTripWithDriver: Bool, withKey key: String?){
    if mapView.annotations.count == 0 {
      return
    }
    
    var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
    var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
    if forActiveTripWithDriver {
      for annotation in mapView.annotations {
        if let annotation = annotation as? DriverAnnotation {
          if annotation.key == key {
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
          }
        } else {
          topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
          topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
          bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
          bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
        }
      }
    }
    
    for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self){
      topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
      topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
      bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
      bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
    }
    
    var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0))
    region = mapView.regionThatFits(region)
    mapView.setRegion(region, animated: true)
  }
  
  //MARK: - Remove Overlay and Annotation
  func removeOverlayAndAnnotations(forDrivers: Bool?, forPassengers: Bool?){
    for annotation in mapView.annotations {
      if let annotation = annotation as? MKPointAnnotation {
        mapView.removeAnnotation(annotation)
      }
      if forPassengers! {
        if let annotation = annotation as? PassengerAnnotation {
          mapView.removeAnnotation(annotation)
        }
      }
      if forDrivers! {
        if let annotation = annotation as? DriverAnnotation {
          mapView.removeAnnotation(annotation)
        }
      }
    }
    for overlay in mapView.overlays {
      if overlay is MKPolyline {
        mapView.remove(overlay)
      }
    }
  }
  
  //MARK: - Connnect User and Drivers for Trip
  func connectUserAndDriverForTrip(){
    
    DataService.instance.passengerIsOnTrip(passengerKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, tripKey) in
      if isOnTrip == true {
        self.removeOverlayAndAnnotations(forDrivers: false, forPassengers: true)
        
        DataService.instance.REF_TRIPS.child(tripKey!).observeSingleEvent(of: .value, with: { (tripSnapshot) in
          let tripDict = tripSnapshot.value as? Dictionary<String, AnyObject>
          let driverId = tripDict?["driverKey"] as? String
          
          let pickupCoordinateArray = tripDict?["pickupCoordinate"] as! NSArray
          let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
          let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
          let pickupMapItem = MKMapItem(placemark: pickupPlacemark)
          
          DataService.instance.REF_DRIVERS.child(driverId!).child("coordinate").observeSingleEvent(of: .value, with: { (coordinateSnapshot) in
            let coordinateSnapshotArray = coordinateSnapshot.value as! NSArray
            let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateSnapshotArray[0] as! CLLocationDegrees, longitude: coordinateSnapshotArray[1] as! CLLocationDegrees)
            let driverPlaceMark = MKPlacemark(coordinate: driverCoordinate)
            let driverMapitem = MKMapItem(placemark: driverPlaceMark)
            
            let passengerAnnotation = PassengerAnnotation(coordinate: driverCoordinate, key: Auth.auth().currentUser!.uid)
            self.mapView.addAnnotation(passengerAnnotation)
            
            self.searchResultsWithPolyline(originMapItem: driverMapitem, destinationMapItem: pickupMapItem)
            self.requestRideBtn.animateButton(shouldLoad: false, withMessage: "DRIVER COMING")
            self.requestRideBtn.isUserInteractionEnabled = false
          })
          
          DataService.instance.REF_TRIPS.child(tripKey!).observeSingleEvent(of: .value, with: { (tripSnapshot) in
            if tripDict?["tripIsInProgress"] as? Bool == true {
              self.removeOverlayAndAnnotations(forDrivers: true, forPassengers: true)
              
              let destinationCoordinateArray = tripDict?["destinationCoordinate"] as! NSArray
              let destinationCoordinate = CLLocationCoordinate2D(latitude: destinationCoordinateArray[0] as! CLLocationDegrees, longitude: destinationCoordinateArray[1] as! CLLocationDegrees)
              let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate)
              
              self.dropPinFor(placemark: destinationPlaceMark)
              self.searchResultsWithPolyline(originMapItem: pickupMapItem, destinationMapItem: MKMapItem(placemark: destinationPlaceMark))
              
              self.requestRideBtn.setTitle("ON TRIP", for: .normal)
            }
          })
        })
      }
    }
    /*
    DataService.instance.userIsDriver(userKey: Auth.auth().currentUser!.uid) { (status) in
      if status == false {
        DataService.instance.REF_TRIPS.child(Auth.auth().currentUser!.uid).observe(.value, with: { (tripSnapshot) in
          let tripDict = tripSnapshot.value as? Dictionary<String, AnyObject>
          if tripDict?["tripIsAccepted"] as? Bool == true {
            
            let driverId = tripDict?["driverKey"] as? String
            let pickupCoordinateArray = tripDict?["pickupCoordinate"] as! NSArray
            let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
            let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
            let pickupMapItem = MKMapItem(placemark: pickupPlacemark)
            
            DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (driverSnapshot) in
              if let driverSnapshot = driverSnapshot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                  if driver.key == driverId {
                    let driverCoordinateArray = driver.childSnapshot(forPath: "coordinate").value as! NSArray
                    let driverCoordinate = CLLocationCoordinate2D(latitude: driverCoordinateArray[0] as! CLLocationDegrees, longitude: driverCoordinateArray[1] as! CLLocationDegrees)
                    let driverPlacemark = MKPlacemark(coordinate: driverCoordinate)
                    let driverMapItem = MKMapItem(placemark: driverPlacemark)
                    let passengerAnnotation = PassengerAnnotation(coordinate: driverCoordinate, key: Auth.auth().currentUser!.uid)
                    //let driverAnnotation = DriverAnnotation(coordinate: driverCoordinate, withKey: driverId!)
                    self.mapView.addAnnotation(passengerAnnotation)
                    self.searchResultsWithPolyline(originMapItem: driverMapItem, destinationMapItem: pickupMapItem)
                    self.requestRideBtn.animateButton(shouldLoad: false, withMessage: "DRIVER COMING")
                    self.requestRideBtn.isUserInteractionEnabled = false
                  }
                }
              }
            })
          }
        })
      }
    }
    */
  }

  func setCustomRegion(forAnnotationType type: AnnotationType, withCoordinate coordinate: CLLocationCoordinate2D){
    if type == .pickUp {
      let pickupRegion = CLCircularRegion(center: coordinate, radius: 100, identifier: "pickUp")
      locationManager?.startMonitoring(for: pickupRegion)
    } else if type == .destination {
      let destinationRegion = CLCircularRegion(center: coordinate, radius: 100, identifier: "destination")
      locationManager?.startMonitoring(for: destinationRegion)
    }
  }
}

//MARK: Location manager delegate
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
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, passengerKey) in
      if isOnTrip == true {
        if region.identifier == "pickUp" {
          self.actionForButton = .startTrip
          self.requestRideBtn.setTitle("START TRIP", for: .normal)
        } else if region.identifier == "destination" {
          self.btnCancel.fadeTo(alpha: 0.0, withDuration: 0.2)
          self.btnCancel.isHidden = true
          self.requestRideBtn.setTitle("END TRIP", for: .normal)
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    DataService.instance.driverIsOnTrip(driverKey: Auth.auth().currentUser!.uid) { (isOnTrip, driverKey, passengerKey) in
      if isOnTrip == true {
        if region.identifier == "pickUp" {
          // TODO: Call an action on the button that will load directions to passenger pickup
          self.requestRideBtn.setTitle("GET DIRECTIONS", for: .normal)
        } else if region.identifier == "destination" {
          // TODO: Call an action on the button that will load directions to destination
          self.requestRideBtn.setTitle("GET DIRECTIONS", for: .normal)
          
        }
      }
    }
  }
}

//MARK: TextField Delegate
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
    matchingItems = []
    self.tableView.reloadData()
    
    DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).child("tripCoordinate").removeValue()
    
    mapView.removeOverlays(mapView.overlays)
    for annotation in mapView.annotations {
      if annotation is MKPointAnnotation{
        mapView.removeAnnotation(annotation)
      } else if annotation.isKind(of: PassengerAnnotation.self){
        mapView.removeAnnotation(annotation)
      }
    }
    
    
    centerMapUserLocation()
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == destinationTexfield {
      performSearch()
      shouldPresentLoadingView(status: true)
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

//MARK: TableView Delegate/Data source
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
    let mapItem = matchingItems[indexPath.row]
    cell.textLabel?.text = mapItem.name
    cell.detailTextLabel?.text = mapItem.placemark.title
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    shouldPresentLoadingView(status: true)
    
    let coordinate = locationManager?.location?.coordinate
    let passengerAnnotation = PassengerAnnotation(coordinate: coordinate!, key: Auth.auth().currentUser!.uid)
    mapView.addAnnotation(passengerAnnotation)
    
    destinationTexfield.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
    
    let selectMapItem = matchingItems[indexPath.row]
    DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).updateChildValues(["tripCoordinate": [selectMapItem.placemark.coordinate.latitude, selectMapItem.placemark.coordinate.longitude]])
    
    dropPinFor(placemark: selectMapItem.placemark)
    
    searchResultsWithPolyline(originMapItem: nil, destinationMapItem: selectMapItem)
    
    animateTableView(shouldShow: false)
    print("Selected!")
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    view.endEditing(true)
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if destinationTexfield.text?.isEmpty == true {
      animateTableView(shouldShow: false)
    }
  }
}
