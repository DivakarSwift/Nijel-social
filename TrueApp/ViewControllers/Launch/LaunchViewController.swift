//
//  LaunchViewController.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 9/26/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import ProgressHUD

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
            ProgressHUD.show()
            Api.User.observeCurrentUser{ (user) in
                let user = user
                let profileVC = UserPostsViewController.instantiate(user: user, type: .myPosts)
                let navigationVC = UINavigationController(rootViewController: profileVC)
                navigationVC.view.backgroundColor = UIColor.white
                vc.viewControllers?[0] = navigationVC
                ProgressHUD.dismiss()
                self.present(vc, animated: false, completion: nil)
            }
        } else {
            let vc = LaunchScreenViewController.instantiate()
            self.present(vc, animated: false, completion: nil)
        }
    }
    
}
