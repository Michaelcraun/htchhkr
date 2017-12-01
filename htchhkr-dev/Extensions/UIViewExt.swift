//
//  UIViewExt.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit

extension UIView {
    func fadeAlphaTo(_ alpha: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alpha
        }
    }
    
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curveFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curveFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: UIViewKeyframeAnimationOptions(rawValue: curve),
                                animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}
