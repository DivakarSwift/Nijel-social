//
//  TrueSettingsViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/1/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth

class TrueSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func logOutAction(sender: AnyObject) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main.storyboard", bundle: nil).instantiateViewController(withIdentifier: "LogInViewController")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
    }
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let logInVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        self.present(logInVC, animated: true, completion: nil)
        
    }

    
}
