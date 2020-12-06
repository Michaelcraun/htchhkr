//
//  Alertable.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 12/5/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

protocol Alertable {  }

extension Alertable where Self: UIViewController {
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error:", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
