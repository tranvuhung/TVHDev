//
//  UpdateServices.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/4/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import MapKit

class UpdateServices {
  static let instance = UpdateServices()
  
  func updateUserLocation(withCoordinate coordinate: CLLocationCoordinate2D){
    DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
      if let userSnaphot = snapshot.children.allObjects as? [DataSnapshot] {
        for user in userSnaphot {
          if user.key == Auth.auth().currentUser?.uid {
            DataService.instance.REF_USERS.child(user.key).updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
          }
        }
      }
    }
  }
  
  func updateDriverLocation(withCoordinate coordinate: CLLocationCoordinate2D){
    DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value) { (snapshot) in
      if let driverSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
        for driver in driverSnapshot{
          if driver.key == Auth.auth().currentUser?.uid{
            if driver.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true {
              DataService.instance.REF_DRIVERS.child(driver.key).updateChildValues(["coordinate": [coordinate.latitude, coordinate.longitude]])
            }
          }
        }
      }
    }
  }
  
  func observeTrips(handler: @escaping(_ coordinateDict: Dictionary<String, AnyObject>?) -> Void){
    DataService.instance.REF_TRIPS.observe(.value) { (snapshot) in
      if let tripSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
        for trip in tripSnapshot{
          if trip.hasChild("passengerKey") && trip.hasChild("tripIsAccepted") {
            if let tripDict = trip.value as? Dictionary<String, AnyObject>{
              handler(tripDict)
            }
          }
        }
      }
    }
  }
  
  func updateTripWithCoordinatesUponRequest(){
    DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
      if let userSnapshot = snapshot.children.allObjects as? [DataSnapshot]{
        for user in userSnapshot {
          if user.key == Auth.auth().currentUser?.uid{
            if !user.hasChild("userIsDriver"){
              guard let userDict = user.value as? Dictionary<String, AnyObject> else {return}
              let pickUpArray = userDict["coordinate"] as! NSArray
              let destionationArray = userDict["tripCoordinate"] as! NSArray
              
              DataService.instance.REF_TRIPS.child(user.key).updateChildValues(["pickupCoordinate": [pickUpArray[0], pickUpArray[1]], "destinationCoordinate": [destionationArray[0], destionationArray[1]], "passengerKey": user.key, "tripIsAccepted": false])
            }
          }
        }
      }
    }
  }
  
  func acceptTrip(withPassenger passengerKey: String, forDriver driverKey: String){
    DataService.instance.REF_TRIPS.child(passengerKey).updateChildValues(["driverKey": driverKey, "tripIsAccepted": true])
    DataService.instance.REF_DRIVERS.child(driverKey).updateChildValues(["driverIsOnTrip": true])
  }
  
  func cancelTrip(withPassenger passengerKey: String, forDriver driverKey: String){
    DataService.instance.REF_TRIPS.child(passengerKey).removeValue()
    DataService.instance.REF_USERS.child(passengerKey).child("tripCoordinate").removeValue()
    DataService.instance.REF_DRIVERS.child(driverKey).updateChildValues(["driverIsOnTrip": false])
  }
  
}
