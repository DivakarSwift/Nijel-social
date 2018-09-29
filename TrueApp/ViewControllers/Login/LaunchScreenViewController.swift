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
    
    @IBAction func logIn(_ sender: UIButton) {
        let vc = LoginViewController.instantiate()
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
