//
//  MenuVC.swift
//  htchhkr-dev
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import Firebase

class MenuVC: UIViewController {
    
    let appDelegate = AppDelegate.getAppDelegate()

    @IBOutlet var signUpLoginButton: UIButton!
    @IBOutlet var userEmail: UILabel!
    @IBOutlet var userAccountType: UILabel!
    @IBOutlet var userImage: RoundImageView!
    @IBOutlet var pickUpModeLabel: UILabel!
    @IBOutlet var pickUpToggle: UISwitch!
    
    var currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickUpToggle.isOn = false
        pickUpModeLabel.isHidden = true
        pickUpToggle.isHidden = true
        
        observePassengersAndDrivers()
        
        if FIRAuth.auth()?.currentUser == nil {
            userEmail.text = ""
            userAccountType.text = ""
            userImage.isHidden = true
            signUpLoginButton.setTitle("SIGN UP / LOGIN", for: .normal)
        } else {
            userEmail.text = FIRAuth.auth()?.currentUser?.email
            userAccountType.text = ""
            userImage.isHidden = false
            signUpLoginButton.setTitle("LOG OUT", for: .normal)
        }
        
        print(pickUpToggle.frame)
        print(pickUpToggle.isHidden)
    }
    
    func observePassengersAndDrivers() {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if snap.key == self.currentUserID {
                        self.userAccountType.text = "PASSENGER"
                    }
                }
            }
        })
        
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if snap.key == self.currentUserID {
                        let switchStatus = snap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                        self.userAccountType.text = "DRIVER"
                        self.pickUpModeLabel.isHidden = false
                        self.pickUpToggle.isHidden = false
                        self.pickUpToggle.isOn = switchStatus
                    }
                }
            }
        })
    }
    
    @IBAction func signUpLoginButtonWasPressed(_ sender: Any) {
        if currentUserID == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            present(loginVC!, animated: true, completion: nil)
        } else {
            do {
                try FIRAuth.auth()?.signOut()
                userEmail.text = ""
                userAccountType.text = ""
                pickUpModeLabel.text = ""
                userImage.isHidden = true
                pickUpToggle.isHidden = true
                signUpLoginButton.setTitle("SIGN UP / LOGIN", for: .normal)
                currentUserID = nil
            } catch (let error) {
                print(error)
            }
        }
    }
    
    @IBAction func pickUpToggleWasToggled(_ sender: Any) {
        if pickUpToggle.isOn {
            pickUpModeLabel.text = "PICKUP MODE ENABLED"
            appDelegate.MenuContainerVC.toggleLeftPanel()
            DataService.instance.REF_DRIVERS.child(currentUserID!).updateChildValues(["isPickUpModeEnabled" : true])
        } else {
            pickUpModeLabel.text = "PICKUP MODE DISABLED"
            DataService.instance.REF_DRIVERS.child(currentUserID!).updateChildValues(["isPickUpModeEnabled": false])
            appDelegate.MenuContainerVC.toggleLeftPanel()
        }
    }
}
