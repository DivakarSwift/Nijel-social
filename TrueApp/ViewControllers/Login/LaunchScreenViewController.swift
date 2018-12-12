//
//  LaunchScreenViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/19/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
//import Firebase

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var retrieveAccountButton: UIButton!
    
    @IBAction func retrieveAccountAction(_ sender:
        UIButton) {
        // go to log in view controller with alert up
        print("retrieveAccount action pressed")
        let vc = LoginViewController.instantiate(showActivationCode: true)
        present(vc, animated: false, completion: nil)
        //loginwithcode
    }
    @IBAction func logIn(_ sender: UIButton) {
        let vc = LoginViewController.instantiate(showActivationCode: false)
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        let vc = SignUpViewController.instantiate()
        present(vc, animated: false, completion: nil)
    }
    
    class func instantiate() -> LaunchScreenViewController {
        return StoryboardControllerProvider<LaunchScreenViewController>.controller(storyboardName: "LoginViewController")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
