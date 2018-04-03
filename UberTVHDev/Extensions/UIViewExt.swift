//
//  UIViewExt.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/2/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func fadeTo(alpha: CGFloat, withDuration: TimeInterval){
    UIView.animate(withDuration: withDuration, animations: {
      self.alpha = alpha
    })
  }
  
  func bindToKyboard(){
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
  }
  
  @objc func keyboardWillChange(_ notification: NSNotification){
    let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
    let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
    let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let deltaY = targetFrame.origin.y - curFrame.origin.y
    
    UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
      self.frame.origin.y += deltaY
    }, completion: nil)
  }
}
