//
//  SettingsViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/27/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import ProgressHUD

class SettingsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func AboutUS(_ sender: Any) {
    }
    
    @IBAction func Trophies(_ sender: Any) {
    }
    
    
//    @IBAction func logOutAction(_ sender: Any) {
//        AuthServiceViewController.logout(onSuccess:{
//         let vc = UIStoryboard(name: "Main.storyboard", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
//            self.present(vc, animated: true, completion: nil)}) {(errorMessage) in
//            ProgressHUD.showError(errorMessage)
//    }
//    }
    
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInVC = storyboard.instantiateViewController(withIdentifier: "LogInViewController")
        self.present(logInVC, animated: true, completion: nil)
        
    }
}
