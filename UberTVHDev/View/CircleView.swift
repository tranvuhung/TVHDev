//
//  CircleView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class CircleView: UIView {

  @IBInspectable var borderColor: UIColor? {
    didSet{
      setupView()
    }
  }
  override func awakeFromNib() {
    setupView()
  }
  
  func setupView(){
    self.layer.borderWidth = 1.5
    self.layer.cornerRadius = self.frame.width / 2
    self.layer.borderColor = borderColor?.cgColor
  }

}
