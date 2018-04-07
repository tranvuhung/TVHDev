//
//  UIViewControllerExtensions.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/7/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

extension UIViewController {
  func shouldPresentLoadingView(status: Bool) {
    let fadeView: UIView?
    
    if status == true {
      fadeView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
      fadeView?.backgroundColor = UIColor.black
      fadeView?.alpha = 0.0
      fadeView?.tag = 90
      
      let spinner = UIActivityIndicatorView()
      spinner.color = UIColor.white
      spinner.activityIndicatorViewStyle = .whiteLarge
      spinner.center = view.center
      
      view.addSubview(fadeView!)
      fadeView?.addSubview(spinner)
      
      spinner.startAnimating()
      
      fadeView?.fadeTo(alpha: 0.7, withDuration: 0.2)
    } else {
      for subview in view.subviews {
        if subview.tag == 90 {
          UIView.animate(withDuration: 0.2, animations: {
            subview.alpha = 0.0
          }) { (finished) in
            subview.removeFromSuperview()
          }
        }
      }
    }
  }
}
