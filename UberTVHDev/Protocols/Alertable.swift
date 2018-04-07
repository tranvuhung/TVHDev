//
//  Alertable.swift
//  UberTVHDev
//
//  Created by Tran Vu Hung on 4/7/18.
//  Copyright © 2018 Tran Vu Hung. All rights reserved.
//

import UIKit

protocol Alertable {}

extension Alertable where Self: UIViewController {
  func showAlert(_ msg: String){
    let alertController = UIAlertController(title: "Error:", message: msg, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(action)
    present(alertController, animated: true, completion: nil)
  }
}
