//
//  CircleView.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class CircleView: UIView {

    override func awakeFromNib() {
        setupView()
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            setupView()
        }
    }
    
    func setupView() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = 1.5
        self.layer.borderColor = borderColor.cgColor
    }
}
