//
//  RoundedTextField.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {
    
    let textRectOffset: CGFloat = 20

    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0 + textRectOffset,
                      y: 0 + textRectOffset / 2,
                      width: self.frame.width - textRectOffset,
                      height: self.frame.height + textRectOffset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0 + textRectOffset,
                      y: 0 + textRectOffset / 2,
                      width: self.frame.width - textRectOffset,
                      height: self.frame.height + textRectOffset)
    }
}
