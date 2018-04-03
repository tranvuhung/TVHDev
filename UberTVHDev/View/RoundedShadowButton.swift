//
//  RoundedShadowButton.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/29/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class RoundedShadowButton {
  
  static let sharedInstance = RoundedShadowButton()
  
  func animateButton(shouldLoad: Bool, withMessage message: String?, requsetBtn: UIButton){
    
    let originalSize = requsetBtn.frame
    let spinner = UIActivityIndicatorView()
    spinner.activityIndicatorViewStyle = .whiteLarge
    spinner.color = UIColor.darkGray
    spinner.alpha = 0.0
    spinner.hidesWhenStopped = true
    spinner.tag = 25
    
    if shouldLoad {
      requsetBtn.addSubview(spinner)
      requsetBtn.setTitle("", for: .normal)
      UIView.animate(withDuration: 0.2, animations: {
        requsetBtn.layer.cornerRadius = requsetBtn.frame.height / 2
        requsetBtn.frame = CGRect(x: requsetBtn.frame.midX - (requsetBtn.frame.height / 2), y: requsetBtn.frame.origin.y, width: requsetBtn.frame.height, height: requsetBtn.frame.height)
      }, completion: { (finished) in
        if finished == true {
          spinner.startAnimating()
          spinner.center = CGPoint(x: requsetBtn.frame.width / 2 + 1, y: requsetBtn.frame.width / 2 + 1)
          spinner.fadeTo(alpha: 1.0, withDuration: 0.2)
        }
      })
      requsetBtn.isUserInteractionEnabled = false
    } else {
      requsetBtn.isUserInteractionEnabled = true
      for subview in requsetBtn.subviews {
        if subview.tag == 25 {
          subview.removeFromSuperview()
        }
      }
      UIView.animate(withDuration: 0.2, animations: {
        requsetBtn.layer.cornerRadius = 5.0
        requsetBtn.frame = originalSize
        requsetBtn.setTitle(message, for: .normal)
      })
    }
  }
}
