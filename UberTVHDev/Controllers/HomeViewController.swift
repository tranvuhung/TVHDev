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

class HomeViewController: UIViewController, MKMapViewDelegate, Alertable {
  
  @IBOutlet weak var requestRideBtn: RoundedButton!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var centerMapBtn: UIButton!
  @IBOutlet weak var destinationTexfield: UITextField!
  @IBOutlet weak var destinationCircleView: CircleView!
  
  let tableView = UITableView()
  
  var delegateExpanded: CenterVCDelegate?
  
  var locationManager: CLLocationManager?
  var regionRadius: CLLocationDistance = 1000
  
  let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "appicon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)
  
  var matchingItems: [MKMapItem] = [MKMapItem]()
  
  let currentUserId = Auth.auth().currentUser?.uid
  
  var selectedItemPlacemark: MKPlacemark? = nil
  
  var router: MKRoute!

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
    
    DataService.instance.driverIsAvailable(key: Auth.auth().currentUser!.uid) { (status) in
      if status == false {
        DataService.instance.REF_TRIPS.observeSingleEvent(of: .value, with: { (tripSnapshot) in
          if let tripSnapshot = tripSnapshot.children.allObjects as? [DataSnapshot] {
            for trip in tripSnapshot {
              if trip.childSnapshot(forPath: "driverKey").value as? String == Auth.auth().currentUser!.uid {
                let pickupCoordinateArray = trip.childSnapshot(forPath: "pickupCoordinate").value as! NSArray
                let pickupCoordinate = CLLocationCoordinate2D(latitude: pickupCoordinateArray[0] as! CLLocationDegrees, longitude: pickupCoordinateArray[1] as! CLLocationDegrees)
                let pickupPlacemark = MKPlacemark(coordinate: pickupCoordinate)
                
                self.dropPinFor(placemark: pickupPlacemark)
                self.searchResultsWithPolyline(forMapItems: MKMapItem(placemark: pickupPlacemark))
              }
            }
          }
        })
      }
    }
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
    UpdateServices.instance.updateTripWithCoordinatesUponRequest()
    requestRideBtn.animateButton(shouldLoad: true, withMessage: nil)
    self.view.endEditing(true)
    destinationTexfield.isUserInteractionEnabled = false
  }
  
  //MARK: - Open Left side controller
  @IBAction func openLeftMenuPress(_ sender: Any) {
    delegateExpanded?.toggoleLeftPanel()
  }
  
  //MARK: - Center user location
  @IBAction func centerUserLocationAction(_ sender: Any) {
    DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
      if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
        for user in userSnapshot {
          if user.key == Auth.auth().currentUser!.uid {
            if user.hasChild("tripCoordinate") {
              self.zoom(toFitAnnotationsFromMapView: self.mapView)
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
  func searchResultsWithPolyline(forMapItems mapItem: MKMapItem){
    let requset = MKDirectionsRequest()
    requset.source = MKMapItem.forCurrentLocation()
    requset.destination = mapItem
    requset.transportType = MKDirectionsTransportType.automobile
    
    let direction = MKDirections(request: requset)
    direction.calculate { (response, error) in
      guard let response = response else {
        self.showAlert("An unexpected error occurred. Please try again.")
        print(error.debugDescription)
        return
      }
      self.router = response.routes[0]
      self.mapView.add(self.router.polyline)
      
      let delegate = AppDelegate.getAppDelegate()
      delegate.window?.rootViewController?.shouldPresentLoadingView(status: false)
    }
    
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let lineRenderer = MKPolylineRenderer(overlay: self.router.polyline)
    lineRenderer.strokeColor = UIColor(red: 216/255, green: 71/255, blue: 30/255, alpha: 0.75)
    lineRenderer.lineWidth = 3
    
    shouldPresentLoadingView(status: false)
    
    zoom(toFitAnnotationsFromMapView: self.mapView)
    
    return lineRenderer
  }
  
  //MARK:  Zooming in on mapview
  func zoom(toFitAnnotationsFromMapView mapView: MKMapView){
    if mapView.annotations.count == 0 {
      return
    }
    
    var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
    var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
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
    
    searchResultsWithPolyline(forMapItems: selectMapItem)
    
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
