//
//  RoundImageView.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
    }

}
