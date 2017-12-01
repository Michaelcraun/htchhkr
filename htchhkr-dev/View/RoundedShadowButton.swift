//
//  RoundedShadowButton.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {
    
    var originalSize: CGRect?

    override func awakeFromNib() {
        setupView()
    }

    func setupView() {
        originalSize = self.frame
        
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
    }
    
    func animateButton(shouldLoad: Bool, withMessage message: String?) {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.color = UIColor.darkGray
        spinner.alpha = 0
        spinner.tag = 1010
        spinner.hidesWhenStopped = true
        
        if shouldLoad {
            self.addSubview(spinner)
            spinner.startAnimating() 
            self.setTitle("", for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.cornerRadius = self.frame.height / 2
                self.frame = CGRect(x: self.frame.midX - (self.frame.height / 2),
                                    y: self.frame.origin.y,
                                    width: self.frame.height,
                                    height: self.frame.height)
            }, completion: { (success) in
                if success {
                    spinner.center = CGPoint(x: self.frame.width / 2 + 1, y: self.frame.width / 2 + 1)
                    spinner.fadeAlphaTo(1.0, withDuration: 0.2)
                }
            })
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
            
            for subview in self.subviews {
                if subview.tag == 1010 {
                    subview.removeFromSuperview()
                }
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.layer.cornerRadius = 5
                self.frame = self.originalSize!
                self.setTitle(message, for: .normal)
            })
        }
    }
}
