//
//  ViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/27/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1)
    
    SetupViewConstraints.sharedInstance.mapView.delegate = self
    
    view.addSubview(SetupViewConstraints.sharedInstance.mapView)
    SetupViewConstraints.sharedInstance.mapView.anchorToTop(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    SetupViewConstraints.sharedInstance.setupView()
    SetupViewConstraints.sharedInstance.constraintPickRide()
    
    SetupViewConstraints.sharedInstance.requestRide.addTarget(self, action: #selector(animateShadowRoundedButton), for: .touchUpInside)
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  @objc private func animateShadowRoundedButton() {
    RoundedShadowButton.sharedInstance.animateButton(shouldLoad: true, withMessage: nil, requsetBtn: SetupViewConstraints.sharedInstance.requestRide)
  }

}
