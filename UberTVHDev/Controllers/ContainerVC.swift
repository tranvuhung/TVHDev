//
//  ContainerVC.swift
//
//  Created by Tran Vu Hung on 3/29/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
  case collapsed
  case leftPanelExpanded
}

enum ShowWichVC {
  case homeVC
}

var showVC: ShowWichVC = .homeVC

class ContainerVC: UIViewController {
  
  var homeVC: HomeViewController!
  var leftVC: LeftMenuPanelViewController!
  var centerViewController: UIViewController!
  var currentState: SlideOutState = .collapsed {
    didSet {
      let shouldShadow = (currentState != .collapsed)
      shouldShowShadow(status: shouldShadow)
    }
  }
  var isHidden = false
  var centerPanelExpandedOffset: CGFloat = 160
  var tap: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initCenter(screen: showVC)
  }
  
  func initCenter(screen: ShowWichVC) {
    var presentingController: UIViewController
    
    showVC = screen
    if homeVC == nil {
      homeVC = UIStoryboard.homeViewController()
      homeVC.delegate = self
    }
    
    presentingController = homeVC
    
    if let con = centerViewController {
      con.view.removeFromSuperview()
      con.removeFromParentViewController()
    }
    
    centerViewController = presentingController
    view.addSubview(centerViewController.view)
    addChildViewController(centerViewController)
    centerViewController.didMove(toParentViewController: self)
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return UIStatusBarAnimation.slide
  }
  
  override var prefersStatusBarHidden: Bool {
    return isHidden
  }
}

extension ContainerVC: CenterVCDelegate {
  
  func toggoleLeftPanel() {
    let notAlreadyExpanded = (currentState != .leftPanelExpanded)
    if notAlreadyExpanded {
      addLeftPanelViewController()
    }
    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }
  
  func addLeftPanelViewController() {
    if leftVC == nil {
      
      leftVC = UIStoryboard.leftViewController()
      
      addChildSidePanelViewController(leftVC!)
    }
  }
  
  func addChildSidePanelViewController(_ sidePanelViewController: LeftMenuPanelViewController) {
    view.insertSubview(sidePanelViewController.view, at: 0)
    addChildViewController(sidePanelViewController)
    sidePanelViewController.didMove(toParentViewController: self)
  }
  
  @objc func animateLeftPanel(shouldExpand: Bool) {
    
    if shouldExpand {
      
      isHidden = !isHidden
      
      animateStatusBar()
      
      setupWhiteCoverView()
      
      currentState = .leftPanelExpanded
      
      animateCenterPanelXPosition(targetPosition: centerViewController.view.frame.width - centerPanelExpandedOffset)
    } else {
      
      isHidden = !isHidden
      
      animateStatusBar()
      
      hideWhiteCoverView()
      
      animateCenterPanelXPosition(targetPosition: 0, completion: { (finished) in
        if finished == true {
          self.currentState = .collapsed
          self.leftVC = nil // stỏryboad
          //self.leftVC.dismiss(animated: true, completion: nil) // code
        }
      })
    }
    
  }
  
  func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil ) {
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
      self.centerViewController.view.frame.origin.x = targetPosition
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
    
    centerViewController.view.addSubview(whiteCoverView)
    whiteCoverView.fadeTo(alpha: 0.75, withDuration: 0.2)
    
    tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel(shouldExpand:)))
    tap.numberOfTapsRequired = 1
    
    self.centerViewController.view.addGestureRecognizer(tap)
  }
  
  func hideWhiteCoverView(){
    self.centerViewController.view.removeGestureRecognizer(tap)
    for subview in centerViewController.view.subviews{
      if subview.tag == 21 {
        UIView.animate(withDuration: 0.2, animations: {
          subview.alpha = 0.0
        }, completion: { (finished) in
          subview.removeFromSuperview()
        })
      }
    }
  }
  
  func shouldShowShadow(status: Bool) {
    if status == true {
      centerViewController.view.layer.shadowOpacity = 0.6
    } else {
      centerViewController.view.layer.shadowOpacity = 0.0
    }
  }
  
}

private extension UIStoryboard {
  class func mainStoryboard() -> UIStoryboard {
    return UIStoryboard(name: "Main", bundle: Bundle.main)
  }
  
  class func leftViewController() -> LeftMenuPanelViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "LeftMenuPanelViewController") as? LeftMenuPanelViewController
  }
  
  class func homeViewController() -> HomeViewController? {
    return mainStoryboard().instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
  }
  
  class func leftSidePanelVC() -> LeftSidePanelVC? {
    return mainStoryboard().instantiateViewController(withIdentifier: "LeftSidePanelVC") as? LeftSidePanelVC
  }
}
