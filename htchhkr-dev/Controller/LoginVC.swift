//
//  LoginVC.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate, Alertable {

    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var emailField: RoundedTextField!
    @IBOutlet var passwordField: RoundedTextField!
    @IBOutlet var authButton: RoundedShadowButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        view.bindToKeyboard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }

    @IBAction func cancelButtonWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func authButtonWasPressed(_ sender: Any) {
        if emailField.text != nil && passwordField.text != nil {
            authButton.animateButton(shouldLoad: true, withMessage: nil)
            view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text {
                FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error == nil {
                        if let user = user {
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                let userData = ["provider" : user.providerID] as [String : Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                            } else {
                                let userData = ["provider" : user.providerID,
                                                "userIsDriver" : true,
                                                "isPickUpModeEnabled" : false,
                                                "driverIsOnTrip" : false] as [String : Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                            }
                        }
                        print("email user successfully authenticated with firebase.")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                            switch errorCode {
                            case .errorCodeEmailAlreadyInUse: self.showAlert("That email is already in use. Pleas try again.")
                            case .errorCodeWrongPassword: self.showAlert("That is the wrong password. Please try again.")
                            case .errorCodeInvalidEmail: self.showAlert("That is an invalid email. Please try again.")
                            case .errorCodeUserNotFound:
                                FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                                    if error != nil {
                                        if let errorCode = FIRAuthErrorCode(rawValue: error!._code) {
                                            switch errorCode {
                                            case .errorCodeInvalidEmail: self.showAlert("That is an invalid email. Please try again.")
                                            default: self.showAlert("There was an unexpected error. Please try again.")
                                            }
                                        }
                                    } else {
                                        if let user = user {
                                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                                let userData = ["provider" : user.providerID] as [String : Any]
                                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                                            } else {
                                                let userData = ["provider" : user.providerID,
                                                                "userIsDriver" : true,
                                                                "isPickUpModeEnabled" : false,
                                                                "driverIsOnTrip" : false] as [String : Any]
                                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                                            }
                                        }
                                        print("successfully created a new firebase user.")
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            default: self.showAlert("There was an unexpected error. Please try again.")
                            }
                        }
                    }
                })
            }
        }
    }
}
