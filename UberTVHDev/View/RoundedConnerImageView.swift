//
//  RoundedConnerImageView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class RoundedConnerImageView: UIImageView {
  override func awakeFromNib() {
    setupView()
  }
  
  func setupView(){
    self.layer.cornerRadius = 20
    self.clipsToBounds = true
    self.contentMode = UIViewContentMode.scaleAspectFit
  }
}
