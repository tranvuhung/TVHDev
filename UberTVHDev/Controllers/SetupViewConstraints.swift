//
//  SetupViewConstraints.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/29/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import MapKit

class SetupViewConstraints {
  static let sharedInstance = SetupViewConstraints()
  
  //MARK: - Setup MapView
  let mapView: MKMapView = {
    let mapView = MKMapView()
    mapView.translatesAutoresizingMaskIntoConstraints = false
    return mapView
  }()
  
  //MARK: - Setup MenuView
  let menuView: UIView = {
    let menuView = UIView()
    menuView.layer.addSublayer(GradientView.sharedGradientsView.menuGradientView)
    menuView.translatesAutoresizingMaskIntoConstraints = false
    return menuView
  }()
  
  var menuSliderBtn: UIButton = {
    let menuBtn = UIButton()
    menuBtn.setImage(#imageLiteral(resourceName: "menuSliderBtn"), for: UIControlState.normal)
    menuBtn.translatesAutoresizingMaskIntoConstraints = false
    return menuBtn
  }()
  
  let menuTitle: UILabel = {
    let title = UILabel()
    title.text = "TVHDev"
    title.font = UIFont.boldSystemFont(ofSize: 18)
    title.textAlignment = .center
    title.textColor = UIColor.white
    title.translatesAutoresizingMaskIntoConstraints = false
    return title
  }()
  
  let profilePhoto: UIImageView = {
    let pro = UIImageView()
    pro.image = UIImage(named: "noProfilePhoto")
    pro.contentMode = UIViewContentMode.scaleAspectFit
    pro.layer.cornerRadius = 20
    pro.clipsToBounds = true
    pro.translatesAutoresizingMaskIntoConstraints = false
    return pro
  }()
  
  //MARK: setup bottomView
  let requestRide:  UIButton = {
    var request = UIButton()
    request.setTitle("REQUEST RIDE", for: UIControlState.normal)
    request.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
    request.backgroundColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1)
    request.setTitleColor(UIColor.black, for: .normal)
    request.translatesAutoresizingMaskIntoConstraints = false
    
    request.layer.cornerRadius = 5.0
    request.layer.shadowColor = UIColor.darkGray.cgColor
    request.layer.shadowOpacity = 0.3
    request.layer.shadowRadius = 10.0
    request.layer.shadowOffset = CGSize.zero
    
    return request
  }()
  
  let centerMapbtn: UIButton = {
    let centerBtn = UIButton()
    centerBtn.setImage(#imageLiteral(resourceName: "centerMapBtn"), for: .normal)
    centerBtn.translatesAutoresizingMaskIntoConstraints = false
    return centerBtn
  }()
  
  //MARK: Setup pick location
  let pickView: UIView = {
    let pk = UIView()
    pk.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    pk.layer.cornerRadius = 5.0
    pk.layer.shadowOpacity = 0.3
    pk.layer.shadowColor = UIColor.darkGray.cgColor
    pk.layer.shadowRadius = 5.0
    pk.layer.shadowOffset = CGSize(width: 0, height: 5)
    pk.translatesAutoresizingMaskIntoConstraints = false
    return pk
  }()
  
  let mylocationTextField: UITextField = {
    let mylocation = UITextField()
    mylocation.text = "My Location"
    mylocation.borderStyle = UITextBorderStyle.none
    mylocation.isUserInteractionEnabled = false
    mylocation.font = UIFont.init(name: "Avenir Next", size: 16)
    mylocation.translatesAutoresizingMaskIntoConstraints = false
    return mylocation
  }()
  
  let goingTextField: UITextField = {
    let going = UITextField()
    going.placeholder = "Where are you going?"
    going.borderStyle = UITextBorderStyle.none
    going.font = UIFont.init(name: "Avenir Next", size: 16)
    going.textColor = UIColor.darkGray
    going.translatesAutoresizingMaskIntoConstraints = false
    return going
  }()
  
  let lineView: UIView = {
    let lineView = UIView()
    lineView.backgroundColor = UIColor.darkGray
    lineView.translatesAutoresizingMaskIntoConstraints = false
    return lineView
  }()
  
  let locationView: UIView = {
    let locationView = UIView()
    locationView.backgroundColor = UIColor.green
    locationView.layer.cornerRadius = 15 / 2
    locationView.layer.borderWidth = 1.5
    locationView.layer.borderColor = UIColor(red: 14/255, green: 118/255, blue: 60/255, alpha: 1).cgColor
    locationView.translatesAutoresizingMaskIntoConstraints = false
    return locationView
  }()
  
  let goingView: UIView = {
    let goingView = UIView()
    goingView.backgroundColor = UIColor.gray
    goingView.layer.cornerRadius = 15 / 2
    goingView.layer.borderWidth = 1.5
    goingView.layer.borderColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1).cgColor
    goingView.translatesAutoresizingMaskIntoConstraints = false
    return goingView
  }()
  
  //MARK: - Constraint setup view
  func setupView(){
    mapView.addSubview(menuView)
    NSLayoutConstraint.activate([
      menuView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 0),
      menuView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 0),
      menuView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: 0),
      menuView.heightAnchor.constraint(equalToConstant: 64)
      ])
    
    //MARK: Constraint MenuView
    menuView.addSubview(menuTitle)
    NSLayoutConstraint.activate([
      menuTitle.centerXAnchor.constraint(equalTo: menuView.centerXAnchor),
      menuTitle.centerYAnchor.constraint(equalTo: menuView.centerYAnchor)
      ])
    
    menuView.addSubview(menuSliderBtn)
    NSLayoutConstraint.activate([
      menuSliderBtn.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 10),
      menuSliderBtn.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -10),
      menuSliderBtn.heightAnchor.constraint(equalToConstant: 40)
      ])
    
    menuView.addSubview(profilePhoto)
    NSLayoutConstraint.activate([
      profilePhoto.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -10),
      profilePhoto.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -10),
      profilePhoto.heightAnchor.constraint(equalToConstant: 40),
      profilePhoto.widthAnchor.constraint(equalToConstant: 40)
      ])
    
    //MARK: Constraint Bottom
    mapView.addSubview(requestRide)
    NSLayoutConstraint.activate([
      requestRide.leadingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      requestRide.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      requestRide.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
      requestRide.heightAnchor.constraint(equalToConstant: 60)
      ])
    mapView.addSubview(centerMapbtn)
    NSLayoutConstraint.activate([
      centerMapbtn.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      centerMapbtn.bottomAnchor.constraint(equalTo: requestRide.topAnchor, constant: -8),
      centerMapbtn.heightAnchor.constraint(equalToConstant: 40),
      centerMapbtn.widthAnchor.constraint(equalToConstant: 40)
      ])
    
    //MARK: Constraint pick location view
    mapView.addSubview(pickView)
    NSLayoutConstraint.activate([
      pickView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 60),
      pickView.leadingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      pickView.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      pickView.heightAnchor.constraint(equalToConstant: 80)
      ])
  }
  
  func constraintPickRide(){
    pickView.addSubview(mylocationTextField)
    pickView.addSubview(lineView)
    pickView.addSubview(goingTextField)
    pickView.addSubview(locationView)
    pickView.addSubview(goingView)
    NSLayoutConstraint.activate([
      mylocationTextField.topAnchor.constraint(equalTo: pickView.topAnchor, constant: 5),
      mylocationTextField.trailingAnchor.constraint(equalTo: pickView.trailingAnchor, constant: -10),
      mylocationTextField.heightAnchor.constraint(equalToConstant: 20),
      mylocationTextField.widthAnchor.constraint(equalToConstant: 300),
      
      lineView.topAnchor.constraint(equalTo: mylocationTextField.bottomAnchor, constant: 5),
      lineView.trailingAnchor.constraint(equalTo: pickView.trailingAnchor, constant: -15),
      lineView.heightAnchor.constraint(equalToConstant: 1),
      lineView.widthAnchor.constraint(equalToConstant: 290),
      
      goingTextField.topAnchor.constraint(equalTo: lineView.topAnchor, constant: 5),
      goingTextField.trailingAnchor.constraint(equalTo: pickView.trailingAnchor, constant: -10),
      goingTextField.heightAnchor.constraint(equalToConstant: 20),
      goingTextField.widthAnchor.constraint(equalToConstant: 300),
      
      locationView.heightAnchor.constraint(equalToConstant: 15),
      locationView.widthAnchor.constraint(equalToConstant: 15),
      locationView.lastBaselineAnchor.constraint(equalTo: mylocationTextField.lastBaselineAnchor, constant: 10),
      locationView.leadingAnchor.constraint(equalTo: pickView.leadingAnchor, constant: 15),
      
      goingView.heightAnchor.constraint(equalToConstant: 15),
      goingView.widthAnchor.constraint(equalToConstant: 15),
      goingView.lastBaselineAnchor.constraint(equalTo: goingTextField.lastBaselineAnchor, constant: 10),
      goingView.leadingAnchor.constraint(equalTo: pickView.leadingAnchor, constant: 15)
      ])
  }
}

//MARK: Constraint MapView
extension UIView
{
  func anchorToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil) {
    
    anchorWithConstantsToTop(top: top, left: left, bottom: bottom, right: right, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0)
  }
  
  func anchorWithConstantsToTop(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0) {
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top {
      topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
    }
    
    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
    }
    
    if let left = left {
      leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
    }
    
    if let right = right {
      rightAnchor.constraint(equalTo: right, constant: -rightConstant).isActive = true
    }
  }
}
