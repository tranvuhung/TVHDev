//
//  RoundMapView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/9/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import MapKit

class RoundMapView: MKMapView {

  override func awakeFromNib() {
    setupView()
  }
  
  func setupView(){
    self.layer.cornerRadius = self.frame.width / 2
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 10.0
  }

}
