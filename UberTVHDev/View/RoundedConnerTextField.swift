//
//  RoundedConnerTextField.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class RoundedConnerTextField: UITextField {
  
  let rectTextOffSet: CGFloat = 20
  override func awakeFromNib() {
    setupView()
  }

  func setupView(){
    self.layer.cornerRadius = self.frame.height / 2
  }

//  override func textRect(forBounds bounds: CGRect) -> CGRect {
//    return CGRect(x: 0 + rectTextOffSet, y: 0 + (rectTextOffSet / 2), width: self.frame.width - rectTextOffSet, height: self.frame.height + rectTextOffSet)
//  }
//  
//  override func editingRect(forBounds bounds: CGRect) -> CGRect {
//    return CGRect(x: 0 + rectTextOffSet, y: 0 + (rectTextOffSet / 2), width: self.frame.width - rectTextOffSet, height: self.frame.height + rectTextOffSet)
//  }
}
