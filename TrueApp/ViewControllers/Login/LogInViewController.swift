//
//  LogInViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 6/25/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import Firebase //SHouldnt need these
import ProgressHUD
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    
    //@IBOutlet weak var Username: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var Password: UITextField!
    

    @IBOutlet weak var logInButton: UIButton!
    
    
    @IBOutlet weak var ForgotPW: UIButton!
    
    
    @IBOutlet weak var Status: UILabel!
    
    class func instantiate() -> LoginViewController {
        return StoryboardControllerProvider<LoginViewController>.controller(storyboardName: "LoginViewController")!
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        Password.delegate = self
        emailTextField.tag = 0
        Password.tag = 1
        
        emailTextField.backgroundColor = .clear
        emailTextField.tintColor = .black
        emailTextField.textColor = .black
        let bottomLayerUser = CALayer()
        bottomLayerUser.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerUser.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerUser)
        
        Password.backgroundColor = .clear
        Password.tintColor = .black
        Password.textColor = .black
        let bottomLayerPW = CALayer()
        bottomLayerPW.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerPW.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        Password.layer.addSublayer(bottomLayerPW)
        logInButton.isEnabled = false
        
        handleTextField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       // self.LogInButton.isEnabled = true
    }
    
    func handleTextField(){
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        Password.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    
    @objc func textFieldDidChange(){
        guard let email = emailTextField.text, !email.isEmpty, let password = Password.text, !password.isEmpty else {
           // logInButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            logInButton.isEnabled = false
            return
        }
        logInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        logInButton.backgroundColor = UIColor.black
        logInButton.isEnabled = true
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        let vc = ForgotPWViewController.instantiate()
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        
        if self.emailTextField.text == "" || self.Password.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.Password.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully logged in")
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationHome")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
       AuthServiceViewController.signIn(email: emailTextField.text!, password: Password.text!, onSuccess: {
        ProgressHUD.showSuccess("Success")
        self.performSegue(withIdentifier: "SignInToTabBarVC", sender: nil)}, onError: { error in
            ProgressHUD.showError(error!)
       })
        
        

    
    }
 

}
