//
//  VerifyPhoneViewController.swift
//  TrueApp
//
//  Created by Sorochinskiy Dmitriy on 26.12.2018.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class VerifyPhoneViewController: UIViewController, AuthUIDelegate {
    
    enum NextViewController {
        case main, settings
    }
    
    let userApi = UserApi()
    var user: User!
    var verificationID = ""
    var nextViewController = NextViewController.main
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtaintUser()
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        verifyButton.setTitleColor(.black, for: .disabled)
        // Do any additional setup after loading the view.
    }
    

    class func instantiate() -> VerifyPhoneViewController {
        let vc = StoryboardControllerProvider<VerifyPhoneViewController>.controller(storyboardName: "LoginViewController")!
        
        return vc
    }
    
    // MARK: - Actions

    @IBAction func backButtonTouched(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func verifyButtonTouched(_ sender: Any) {
        let creds = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: codeTextField.text ?? "")
        ProgressHUD.show()
        Auth.auth().currentUser?.linkAndRetrieveData(with: creds) { result, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.showError(error: error.localizedDescription)
            } else {
                switch self.nextViewController {
                case .main:
                    self.gotoMain()
                case .settings:
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func getVerificationNumber() {
        PhoneAuthProvider.provider().verifyPhoneNumber(user.phoneNumber ?? "", uiDelegate: self) { result, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.showError(error: error.localizedDescription)
            } else if let result = result {
                self.verificationID = result
            } else {
                self.showError(error: "Unknown error")
            }
        }
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        verifyButton.isEnabled = sender.text?.count ?? 0 > 0
        verifyButton.backgroundColor = verifyButton.isEnabled ? .blue : .gray
    }
    
    func gotoMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        
        let profileVC = UserPostsViewController.instantiate(user: user, type: .myPosts)
        let navigationVC = UINavigationController(rootViewController: profileVC)
        navigationVC.view.backgroundColor = UIColor.white
        navigationVC.tabBarItem.image = #imageLiteral(resourceName: "home_icon.png")
        vc.viewControllers?[0] = navigationVC
        self.present(vc, animated: false, completion: nil)
    }
    
    func obtaintUser() {
        ProgressHUD.show()
        userApi.observeCurrentUser { user in
            self.user = user
            self.getVerificationNumber()
        }
    }
    
    func showError(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
