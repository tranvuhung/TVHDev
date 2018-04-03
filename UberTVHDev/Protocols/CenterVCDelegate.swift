//
//  CenterVCDelegate.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 3/29/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

protocol CenterVCDelegate {
  func toggoleLeftPanel()
  func addLeftPanelViewController()
  func animateLeftPanel(shouldExpand: Bool)
}
