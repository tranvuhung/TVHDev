//
//  ViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/27/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView

class HomeViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var requestRideBtn: RoundedButton!
  @IBOutlet weak var mapView: MKMapView!
  var delegate: CenterVCDelegate?
  
  let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "appicon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1)
    
    mapView.delegate = self
    
    self.view.addSubview(revealingSplashView)
    revealingSplashView.animationType = SplashAnimationType.heartBeat
    revealingSplashView.startAnimation()
    revealingSplashView.heartAttack = true
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  //MARK: - Animate Action Request Ride
  @IBAction func requestRideAction(_ sender: Any) {
    requestRideBtn.animateButton(shouldLoad: true, withMessage: nil)
  }
  
  
  //MARK: - Open Left side controller

  @IBAction func openLeftMenuPress(_ sender: Any) {
    delegate?.toggoleLeftPanel()
  }
}
