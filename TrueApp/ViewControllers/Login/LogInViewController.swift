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
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    enum LoginType {
        case none, phoneNumber, email
    }
    
    enum PhoneStep {
        case none, notSent, sent
    }
    
    //@IBOutlet weak var Username: UITextField!
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var ForgotPW: UIButton!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    var showActivationCode: Bool? = false
    private var loginType: LoginType = .none {
        didSet {
            switch loginType {
            case .none:
                showDefaultState()
            case .phoneNumber:
                showPhoneState()
            case .email:
                showEmailState()
            }
        }
    }
    
    private var phoneStep: PhoneStep = .notSent {
        didSet {
            switch phoneStep {
            case .sent:
                phoneNumberTextField.isEnabled = false
                passwordTextField.isEnabled = true
                logInButton.isEnabled = true
                logInButton.setTitle("Confirm and login", for: .normal)
            case .notSent:
                phoneNumberTextField.isEnabled = true
                passwordTextField.isEnabled = false
                self.passwordTextField.placeholder = "Code"
                self.logInButton.setTitle("Send code", for: .normal)
            default:
                phoneNumberTextField.isEnabled = true
                passwordTextField.isEnabled = true
                self.logInButton.setTitle("Login", for: .normal)
            }
        }
    }
    
    var verificationID = ""
        
    class func instantiate(showActivationCode:Bool?) -> LoginViewController {
        let lvc = StoryboardControllerProvider<LoginViewController>.controller(storyboardName: "LoginViewController")!
        lvc.showActivationCode = showActivationCode
        return lvc
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 0
        passwordTextField.tag = 1
        phoneNumberTextField.delegate = self
        emailTextField.backgroundColor = .clear
        emailTextField.tintColor = .black
        emailTextField.textColor = .black
        let bottomLayerUser = CALayer()
        bottomLayerUser.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerUser.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerUser)
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.tintColor = .black
        passwordTextField.textColor = .black
        let bottomLayerPW = CALayer()
        bottomLayerPW.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerPW.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPW)
        logInButton.isEnabled = false
        logInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)

        handleTextField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("TITS")
        print(showActivationCode as Any)
        
        if showActivationCode == true{
            loginWithCodeHelper()
        }
    }
    
    func showDefaultState() {
        UIView.animate(withDuration: 0.2) {
            self.passwordTextField.alpha = 0
            self.emailTextField.alpha = 1
            self.phoneNumberTextField.alpha = 1
            self.orLabel.alpha = 1
            self.logInButton.isEnabled = false
            self.logInButton.backgroundColor = .gray
        }
    }
    
    func showPhoneState() {
        UIView.animate(withDuration: 0.2) {
            self.passwordTextField.alpha = 1
            self.logInButton.isEnabled = true
            self.passwordTextField.placeholder = "Code"
            self.emailTextField.alpha = 0
            self.phoneNumberTextField.alpha = 1
            self.orLabel.alpha = 0
        }
    }
    
    func showEmailState() {
        UIView.animate(withDuration: 0.2) {
            self.passwordTextField.isEnabled = true
            self.passwordTextField.alpha = 1
            self.passwordTextField.placeholder = "Password"
            self.emailTextField.alpha = 1
            self.phoneNumberTextField.alpha = 0
            self.orLabel.alpha = 0
        }
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
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            if emailTextField.text?.count ?? 0 > 0 {
                loginType = .email
                logInButton.isEnabled = (emailTextField.text?.count ?? 0 > 0) && (passwordTextField.text?.count ?? 0 > 0)
                logInButton.backgroundColor = logInButton.isEnabled ? .black : .gray
            } else {
                loginType = .none
            }
        }
        
        if sender == phoneNumberTextField {
            if phoneNumberTextField.text?.count ?? 0 > 0 {
                loginType = .phoneNumber
                phoneStep = .notSent
                logInButton.isEnabled = (phoneNumberTextField.text?.count ?? 0 > 0)
                logInButton.backgroundColor = logInButton.isEnabled ? .black : .gray
            } else {
                loginType = .none
                phoneStep = .none
            }
        }
        
        if sender == passwordTextField {
            switch loginType {
            case .email:
                logInButton.isEnabled = (emailTextField.text?.count ?? 0 > 0) && (passwordTextField.text?.count ?? 0 > 0)
                logInButton.backgroundColor = logInButton.isEnabled ? .black : .gray
            case .phoneNumber:
                logInButton.isEnabled = (phoneNumberTextField.text?.count ?? 0 > 0) && (passwordTextField.text?.count ?? 0 > 0)
                logInButton.backgroundColor = logInButton.isEnabled ? .black : .gray
            default:
                logInButton.isEnabled = false
                logInButton.backgroundColor = logInButton.isEnabled ? .black : .gray
            }
        }
        
        return
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
           // logInButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            logInButton.isEnabled = false
            return
        }
        logInButton.backgroundColor = UIColor.black
        logInButton.isEnabled = true
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        let vc = ForgotPWViewController.instantiate()
        present(vc, animated: false, completion: nil)
    }
    
    
    @IBAction func loginWithCode(_ sender: UIButton) {
        loginWithCodeHelper()
    }
    
    func loginWithCodeHelper(){
        let alert = UIAlertController(title: "Log In", message: "Please enter activation code", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Activation code"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            ProgressHUD.show()
            self.searchCodeUser(code: textField.text!, completion: { (completion, id, name) in
                if !completion {
                    ProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "Warning", message: "Wrong activation code", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    ProgressHUD.dismiss()
                    let vc = SignUpViewController.instantiate()
                    vc.activeId = id
                    vc.activeName = name
                    self.present(vc, animated: false, completion: nil)
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchCodeUser(code: String, completion: @escaping(Bool, String, String) ->()) {
        var founded = false
        var snapKey = ""
        var fullName = ""
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as? DataSnapshot
                let dict = snap?.value as! [String: Any]
                if let activationCode = dict["activationCode"] as? String {
                    if activationCode == code {
                        founded = true
                        snapKey = snap!.key as String
                        fullName = (dict["fullName"] as? String)!
                    }
                }
            }
            if founded {
                completion(true, snapKey, fullName)
            } else {
                completion(false, "empty", "empty")
            }
            
        }
    }
    
    
    @IBAction func loginAction(_ sender: AnyObject) {
        switch loginType {
        case .phoneNumber:
            loginWithPhoneNumber()
        case .email:
            loginWithEmail()
        default:
            break
        }
       
    }
    
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        AuthServiceViewController.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
        ProgressHUD.showSuccess("Success")
        self.performSegue(withIdentifier: "SignInToTabBarVC", sender: nil)}, onError: { error in
            ProgressHUD.showError(error!)
       })
    }
    
    func loginWithEmail() {
        ProgressHUD.show()

        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            self.showError(error: "Please enter an email and password.")
            ProgressHUD.dismiss()

        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                if error == nil {
                    print("You have successfully logged in")
                    self.showMainVC()
                    ProgressHUD.dismiss()
                } else {
                    self.showError(error: error?.localizedDescription ?? "")

                    ProgressHUD.dismiss()
                }
            }
        }
    }
    
    func showError(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loginWithPhoneNumber() {
        ProgressHUD.show()
        switch phoneStep {
        case .notSent:
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumberTextField?.text ?? "", uiDelegate: self) { verificationID, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.showError(error: error.localizedDescription)
                } else if let verificationID = verificationID {
                    self.verificationID = verificationID
                    self.phoneStep = .sent
                } else {
                    self.showError(error: "Unknown error")
                }
            }
        case .sent:
            let creds = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: self.passwordTextField.text ?? "")
            Auth.auth().signInAndRetrieveData(with: creds) { (result, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.showError(error: error.localizedDescription)
                } else if let result = result {

                    if result.user.email == nil {
                        ProgressHUD.show()
                        Auth.auth().currentUser?.delete { error in
                            ProgressHUD.dismiss()
                            self.showError(error: error?.localizedDescription ?? "User is unregistered")
                        }
                        
                    } else {
                        self.showMainVC()
                    }
                } else {
                    self.showError(error: "Unknown error")
                }
            }
        default:
            break
        }
    }
    
    func showMainVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        
        Api.User.observeCurrentUser{ (user) in
            let dict = ["deactivated": false]
            Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
                let profileVC = UserPostsViewController.instantiate(user: user, type: .myPosts)
                let navigationVC = UINavigationController(rootViewController: profileVC)
                navigationVC.view.backgroundColor = UIColor.white
                navigationVC.tabBarItem.image = #imageLiteral(resourceName: "home_icon.png")
                vc.viewControllers?[0] = navigationVC
                self.present(vc, animated: false, completion: nil)
            })
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        switch textField {
//        case textField == emailTextField:
//            textField.cou
//        }
        return true
    }
}

extension LoginViewController: AuthUIDelegate {
    
}
