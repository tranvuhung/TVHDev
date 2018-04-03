//
//  ShadowPickLocationView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class ShadowPickLocationView: UIView {
  override func awakeFromNib() {
    setupView()
  }
  
  func setupView(){
    self.layer.cornerRadius = 5.0
    self.layer.shadowOpacity = 0.3
    self.layer.shadowColor = UIColor.darkGray.cgColor
    self.layer.shadowRadius = 5.0
    self.layer.shadowOffset = CGSize(width: 0, height: 5)
  }

}
