//
//  SetupLeftSidePanelVC.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/30/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class SetupLeftSidePanelVC {
  
  static let sharedInstance = SetupLeftSidePanelVC()
  
  //MARK: - Title View Menu
  let menuView: UIView = {
    let menu = UIView()
    menu.backgroundColor = UIColor.darkGray
    menu.translatesAutoresizingMaskIntoConstraints = false
    return menu
  }()
  
  let titleMenu: UILabel = {
    let titleMenu = UILabel()
    titleMenu.text = "Menu"
    titleMenu.textColor = UIColor.white
    titleMenu.font =  UIFont(descriptor: UIFontDescriptor.init(name: "Avenir Next Bold", size: 30), size: 30)
    titleMenu.translatesAutoresizingMaskIntoConstraints = false
    return titleMenu
  }()
  
  func constraintMenuView(_ view: UIView){
    view.addSubview(menuView)
    NSLayoutConstraint.activate([
      menuView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
      menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
      menuView.heightAnchor.constraint(equalToConstant: 130)
      ])
    menuView.addSubview(titleMenu)
    NSLayoutConstraint.activate([
      titleMenu.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 10),
      titleMenu.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 50),
      titleMenu.heightAnchor.constraint(equalToConstant: 100),
      titleMenu.widthAnchor.constraint(equalToConstant: 200)
      ])
  }
  
  //MARK: - Button Menu
  let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = UIStackViewDistribution.fillEqually
    stackView.axis = UILayoutConstraintAxis.vertical
    stackView.alignment = UIStackViewAlignment.leading
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  let paymentButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Payment", for: .normal)
    btn.titleLabel?.font =  UIFont(descriptor: UIFontDescriptor.init(name: "Avenir Next Bold", size: 20), size: 20)
    btn.setTitleColor(UIColor.darkGray, for: .normal)
    btn.titleLabel?.textAlignment = .left
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  let yourTrips: UIButton = {
    let btn = UIButton()
    btn.setTitle("Your Trips", for: .normal)
    btn.titleLabel?.font =  UIFont(descriptor: UIFontDescriptor.init(name: "Avenir Next Bold", size: 20), size: 20)
    btn.setTitleColor(UIColor.darkGray, for: .normal)
    btn.titleLabel?.textAlignment = .left
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  let helpButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Help", for: .normal)
    btn.titleLabel?.font =  UIFont(descriptor: UIFontDescriptor.init(name: "Avenir Next Bold", size: 20), size: 20)
    btn.setTitleColor(UIColor.darkGray, for: .normal)
    btn.titleLabel?.textAlignment = .left
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  let settingButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Settings", for: .normal)
    btn.titleLabel?.textAlignment = .left
    btn.titleLabel?.font = UIFont(descriptor: UIFontDescriptor.init(name: "Avenir Next Bold", size: 20), size: 20)
    btn.setTitleColor(UIColor.darkGray, for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  func buttonConstrainMenu(_ view: UIView){
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: menuView.bottomAnchor, constant: 10),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
      ])
    stackView.addArrangedSubview(paymentButton)
    stackView.addArrangedSubview(yourTrips)
    stackView.addArrangedSubview(helpButton)
    stackView.addArrangedSubview(settingButton)
  }
  
  //MARK: Sign Up/ Login Button
  let signUpLoginButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Sign Up / Login", for: UIControlState.normal)
    btn.titleLabel?.font =  UIFont(descriptor: UIFontDescriptor.init(name: "Avenir Next Bold", size: 20), size: 20)
    
    btn.setTitleColor(UIColor.darkGray, for: .normal)
    btn.titleLabel?.textAlignment = NSTextAlignment.left
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  func signUpConstraint(_ view: UIView){
    view.addSubview(signUpLoginButton)
    NSLayoutConstraint.activate([
      signUpLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      signUpLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      signUpLoginButton.widthAnchor.constraint(equalToConstant: 150)
      ])
  }
}
