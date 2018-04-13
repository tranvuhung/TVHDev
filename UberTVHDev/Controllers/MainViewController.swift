//
//  MainViewController.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/13/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  var homeViewController: HomeViewController!
  var currentState: SlideOutState = .collapsed {
    didSet {
      let shouldShadow = (currentState != .collapsed)
      shouldShowShadow(status: shouldShadow)
    }
  }
  
  var tap: UITapGestureRecognizer!
  @IBOutlet weak var leadingConstraintMenu: NSLayoutConstraint!
  @IBOutlet weak var leftMenu: UIView!
  
  var isHidden = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "HomeVC" {
      let homeVC = segue.destination as! HomeViewController
      homeVC.delegateExpanded = self
      homeViewController = homeVC
    } else if segue.identifier == "LeftMenu" {
      let leftMenuVC = segue.destination as! LeftMenuPanelViewController
      leftMenuVC.delegate = self
    }
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return UIStatusBarAnimation.slide
  }
  
  override var prefersStatusBarHidden: Bool {
    return isHidden
  }
  
}

extension MainViewController: CenterVCDelegate {
  
  func toggoleLeftPanel() {
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)
    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }
  
  @objc func animateLeftPanel(shouldExpand: Bool) {
    if shouldExpand {
      isHidden = !isHidden
      currentState = .leftPanelExpanded
      animateStatusBar()
      setupWhiteCoverView()
      animateLayoutConstraint(constant: 0)
    } else {
      isHidden = !isHidden
      animateStatusBar()
      hideWhiteCoverView()
      animateLayoutConstraint(constant: -210) { (finished) in
        if finished == true {
          self.currentState = .collapsed
        }
      }
    }
  }
  
  func animateLayoutConstraint(constant: CGFloat, completion: ((Bool) -> Void)! = nil) {
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
      self.leadingConstraintMenu.constant = constant
      self.view.layoutIfNeeded()
    }, completion: completion)
  }
  
  func animateStatusBar(){
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
      self.setNeedsStatusBarAppearanceUpdate()
    })
  }
  
  func setupWhiteCoverView(){
    let whiteCoverView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    whiteCoverView.backgroundColor = UIColor.white
    whiteCoverView.tag = 21
    whiteCoverView.alpha = 0.0
    
    homeViewController.view.addSubview(whiteCoverView)
    whiteCoverView.fadeTo(alpha: 0.75, withDuration: 0.5)
    
    tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(shouldExpand:)))
    tap.numberOfTapsRequired = 1
    
    homeViewController.view.addGestureRecognizer(tap)
  }
  
  func hideWhiteCoverView(){
    homeViewController.view.removeGestureRecognizer(tap)
    for subview in homeViewController.view.subviews{
      if subview.tag == 21 {
        UIView.animate(withDuration: 0.5, animations: {
          subview.alpha = 0.0
        }, completion: { (finished) in
          subview.removeFromSuperview()
        })
      }
    }
  }
  
  func shouldShowShadow(status: Bool) {
    if status == true {
      leftMenu.layer.shadowOpacity = 0.6
    } else {
      leftMenu.layer.shadowOpacity = 0.0
    }
  }
  
  //MARK: - Not use
  func addLeftPanelViewController() {
    
  }
}
