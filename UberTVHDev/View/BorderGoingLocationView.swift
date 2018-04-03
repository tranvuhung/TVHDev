//
//  BorderGoingLocationView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class BorderGoingLocationView: UIView {

  override func awakeFromNib() {
    setupView()
  }
  
  func setupView(){
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.borderWidth = 1.5
    self.layer.borderColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1).cgColor
  }

}
