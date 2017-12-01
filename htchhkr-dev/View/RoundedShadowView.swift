//
//  RoundedShadowView.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {

    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        self.layer.cornerRadius = 5
    }
}
