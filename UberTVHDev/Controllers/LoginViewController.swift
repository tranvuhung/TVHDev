//
//  LoginViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var actionBtn: RoundedButton!
  @IBOutlet weak var segmentControll: UISegmentedControl!
  @IBOutlet weak var emailField: RoundedConnerTextField!
  @IBOutlet weak var passwordField: RoundedConnerTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.emailField.delegate = self
    self.passwordField.delegate = self
    
    view.bindToKyboard()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
    self.view.addGestureRecognizer(tap)
  }
  
  @objc func handleScreenTap(sender: UITapGestureRecognizer){
    self.view.endEditing(true)
  }
  
  @IBAction func closeLoginVC(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func actionBtnPress(_ sender: Any) {
    guard emailField.text != nil, passwordField.text != nil else {return}
    actionBtn.animateButton(shouldLoad: true, withMessage: nil)
    self.view.endEditing(true)
    
    guard let email = emailField.text, let password = passwordField.text else {return}
    
    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
      if error == nil {
        guard let user = user else {return}
        
        if self.segmentControll.selectedSegmentIndex == 0 {
          let userData = ["provider": user.providerID] as [String: Any]
          DataService.instance.createFirbaseDBUser(uid: user.uid, userData: userData, isDriver: false)
        } else if self.segmentControll.selectedSegmentIndex == 1 {
          let userData = ["provider": user.providerID, "userIsDriver": true, "isPickupModeEnabled": false, "driverIsOnTrip": false] as [String: Any]
          DataService.instance.createFirbaseDBUser(uid: user.uid, userData: userData, isDriver: true)
          self.dismiss(animated: true , completion: nil)
        }
        
        print("Email user authenticated successfully with Firebase")
        self.dismiss(animated: true , completion: nil)
        
      }
      else {
        if let errorCode = AuthErrorCode(rawValue: error!._code) {
          switch errorCode{
          case .wrongPassword:
            print("Whoops! That was wrong password!")
          case .invalidEmail:
            print("Email invalid. Please try again.")
          default:
            print("An unexpected error occurred. Please try again.")
          }
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
          if error != nil {
            if let errorCode = AuthErrorCode(rawValue: error!._code) {
              switch errorCode{
              case .emailAlreadyInUse:
                print("Email already. Please try again.")
              default:
                print("An unexpected error occurred. Please try again.")
              }
            }
          }
          else {
            guard let user = user else {return}
            
            if self.segmentControll.selectedSegmentIndex == 0 {
              let userData = ["provider": user.providerID] as [String: Any]
              DataService.instance.createFirbaseDBUser(uid: user.uid, userData: userData, isDriver: false)
            } else {
              let userData = ["provider": user.providerID, "userIsDriver": true, "isPickupModeEnabled": false, "driverIsOnTrip": false] as [String: Any]
              DataService.instance.createFirbaseDBUser(uid: user.uid, userData: userData, isDriver: true)
            }
            
            print("Successfully created a new user with Firebase")
            self.dismiss(animated: true , completion: nil)
          }
        })
      }
    }
  }
  
}
