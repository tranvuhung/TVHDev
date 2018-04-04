//
//  LeftMenuPanelViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/30/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import Firebase

class LeftMenuPanelViewController: UIViewController {
  
  let currentUserId = Auth.auth().currentUser?.uid
  
  let appDelegate = AppDelegate.getAppDelegate()
  
  @IBOutlet weak var pickupModeSwitch: UISwitch!
  @IBOutlet weak var pickupModeLabel: UILabel!
  @IBOutlet weak var userIamgeView: RoundedConnerImageView!
  @IBOutlet weak var userEmailLabel: UILabel!
  @IBOutlet weak var acountTypeLabel: UILabel!
  @IBOutlet weak var loginoutBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    pickupModeSwitch.isOn = false
    pickupModeSwitch.isHidden = true
    pickupModeLabel.isHidden = true
    
    observePassengersAndDrivers()
    
    if Auth.auth().currentUser == nil {
      userIamgeView.isHidden = true
      userEmailLabel.text = ""
      acountTypeLabel.text = ""
      pickupModeLabel.isHidden = true
      pickupModeSwitch.isHidden = true
      
      loginoutBtn.setTitle("Sign up / Login", for: .normal)
    } else {
      userEmailLabel.text = Auth.auth().currentUser?.email
      acountTypeLabel.text = ""
      userIamgeView.isHidden = false
      loginoutBtn.setTitle("Logout", for: .normal)
    }
  }
  
  func observePassengersAndDrivers(){
    DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {return}
      for snap in snapshot{
        if snap.key == Auth.auth().currentUser?.uid {
          self.acountTypeLabel.text = "PASSENGER"
        }
      }
    })
    
    DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {return}
      for snap in snapshot{
        if snap.key == Auth.auth().currentUser?.uid {
          self.acountTypeLabel.text = "DRIVER"
          self.pickupModeSwitch.isHidden = false
          
          let switchStatus = snap.childSnapshot(forPath: "isPickupModeEnabled").value as! Bool
          self.pickupModeSwitch.isOn = switchStatus
          self.pickupModeLabel.isHidden = false
        }
      }
    })
  }
  
  @IBAction func switchWasToggle(_ sender: Any) {
    if pickupModeSwitch.isOn{
      pickupModeLabel.text = "PICKUP MODE ENABLED"
      DataService.instance.REF_DRIVERS.child(Auth.auth().currentUser!.uid).updateChildValues(["isPickupModeEnabled": true])
      appDelegate.MenuContainerVC.toggoleLeftPanel()
    } else {
      pickupModeLabel.text = "PICKUP MODE DISABLED"
      DataService.instance.REF_DRIVERS.child(Auth.auth().currentUser!.uid).updateChildValues(["isPickupModeEnabled": false])
      appDelegate.MenuContainerVC.toggoleLeftPanel()
    }
    
    if let uid = currentUserId{
      print("Qua ao =))")
    }
    else {
      print("Deo co cai gi het.....")
    }
  }
  @IBAction func loginActionBtn(_ sender: Any) {
    if Auth.auth().currentUser == nil {
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      let loginVc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
      present(loginVc!, animated: true, completion: nil)
      appDelegate.MenuContainerVC.toggoleLeftPanel()
//      if self.presentingViewController == nil {
//        appDelegate.MenuContainerVC.toggoleLeftPanel()
//      }
    } else {
      do{
        try Auth.auth().signOut()
        userEmailLabel.text = ""
        acountTypeLabel.text = ""
        userIamgeView.isHidden = true
        pickupModeLabel.text = ""
        pickupModeSwitch.isHidden = true
        loginoutBtn.setTitle("Sign up/ Login", for: .normal)
        appDelegate.MenuContainerVC.toggoleLeftPanel()
      } catch let error {
        print(error.localizedDescription)
      }
    }
    
  }
}
