//
//  LeftSidePanelVC.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/29/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

class LeftSidePanelVC: UIViewController {
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    SetupLeftSidePanelVC.sharedInstance.constraintMenuView(self.view)
    SetupLeftSidePanelVC.sharedInstance.buttonConstrainMenu(self.view)
    SetupLeftSidePanelVC.sharedInstance.signUpConstraint(self.view)
  }
  
}
