//
//  ForgotPWViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/29/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPWViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var orTextField: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    class func instantiate() -> ForgotPWViewController {
        return StoryboardControllerProvider<ForgotPWViewController>.controller(storyboardName: "LoginViewController")!
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        phoneNumberTextField.delegate = self
        emailTextField.tag = 0
        phoneNumberTextField.tag = 1
        // Do any additional setup after loading the view.
        
        emailTextField.backgroundColor = .clear
        emailTextField.tintColor = .black
        emailTextField.textColor = .black
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        phoneNumberTextField.backgroundColor = .clear
        phoneNumberTextField.tintColor = .black
        phoneNumberTextField.textColor = .black
        let bottomLayerPN = CALayer()
        bottomLayerPN.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerPN.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        phoneNumberTextField.layer.addSublayer(bottomLayerPN)
        // Do any additional setup after loading the view.
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
    
    @IBAction func submitAction(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Check email for reset message", message: "", preferredStyle: UIAlertController.Style.alert)
        Auth.auth().sendPasswordReset(withEmail: "\(self.emailTextField.text!)") { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        let saveAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { alert -> Void in
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}
