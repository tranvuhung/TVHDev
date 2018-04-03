//
//  BorderMylocationView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class BorderMylocationView: UIView {

  override func awakeFromNib() {
    setupView()
  }
  
  func setupView(){
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.borderColor = UIColor(red: 14/255, green: 118/255, blue: 60/255, alpha: 1).cgColor
    self.layer.borderWidth = 1.5
  }

}
