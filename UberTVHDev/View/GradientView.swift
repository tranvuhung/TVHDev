//
//  GradientView.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/29/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class GradientView: UIView {
  static let sharedGradientsView = GradientView()
  
  let gradient = CAGradientLayer()
  
  override func awakeFromNib() {
    setupGradient()
  }
  
  func setupGradient(){
    gradient.frame = self.bounds
    gradient.colors = [UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1).cgColor, UIColor.init(red: 255/255, green: 128/255, blue: 0, alpha: 0).cgColor]
    gradient.startPoint = CGPoint.zero
    gradient.endPoint = CGPoint(x: 0, y: 1)
    gradient.locations = [0.85, 1.0]
    self.layer.addSublayer(gradient)
  }
  
  var menuGradientView: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 375, height: 64))
    gradient.colors = [UIColor(red: 255/255, green: 128/255, blue: 0, alpha: 1).cgColor, UIColor.init(red: 255/255, green: 128/255, blue: 0, alpha: 0).cgColor]
    gradient.startPoint = CGPoint.zero
    gradient.endPoint = CGPoint(x: 0, y: 1)
    gradient.locations = [0.85, 1.0]
    return gradient
  }()
}
