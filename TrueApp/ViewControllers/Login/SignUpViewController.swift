//
//  AllSignUpViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/27/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import Foundation
import ProgressHUD
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var FullNameTextField: UITextField!
    
    @IBOutlet weak var PhoneNumberTextField: UITextField!
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedImage: UIImage?
    
    class func instantiate() -> SignUpViewController {
        return StoryboardControllerProvider<SignUpViewController>.controller(storyboardName: "LoginViewController")!
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FullNameTextField.delegate = self
        PhoneNumberTextField.delegate = self
        EmailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        FullNameTextField.tag = 0
        PhoneNumberTextField.tag = 1
        EmailTextField.tag = 2
        usernameTextField.tag = 3
        passwordTextField.tag = 4
        
        EmailTextField.backgroundColor = .clear
        EmailTextField.tintColor = .black
        EmailTextField.textColor = .black
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        EmailTextField.layer.addSublayer(bottomLayerEmail)
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.tintColor = .black
        passwordTextField.textColor = .black
        let bottomLayerPW = CALayer()
        bottomLayerPW.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerPW.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPW)
        
        FullNameTextField.backgroundColor = .clear
        FullNameTextField.tintColor = .black
        FullNameTextField.textColor = .black
        let bottomLayerFull = CALayer()
        bottomLayerFull.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerFull.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        FullNameTextField.layer.addSublayer(bottomLayerFull)
        
        PhoneNumberTextField.backgroundColor = .clear
        PhoneNumberTextField.tintColor = .black
        PhoneNumberTextField.textColor = .black
        let bottomLayerPhone = CALayer()
        bottomLayerPhone.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerPhone.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        PhoneNumberTextField.layer.addSublayer(bottomLayerPhone)
        
        usernameTextField.backgroundColor = .clear
        usernameTextField.tintColor = .black
        usernameTextField.textColor = .black
        let bottomLayerUser = CALayer()
        bottomLayerUser.frame = CGRect(x: 0, y: 29, width: 273, height: 0.6)
        bottomLayerUser.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(bottomLayerUser)
        
        profileImage.layer.cornerRadius = 10
        profileImage.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        //signUpButton.isUserInteractionEnabled = false
        handleTextField()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3){
           // self.constraintToBottom.constant = (keyboardFrame!.height) //WONT WORK WITHOUT
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        UIView.animate(withDuration: 0.3){
           // self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func handleTextField(){
        FullNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        PhoneNumberTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        EmailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    @objc func textFieldDidChange(){
        guard let username = usernameTextField.text, !username.isEmpty, let email = EmailTextField.text, !email.isEmpty, let fullname = FullNameTextField.text, !fullname.isEmpty, let phonenumber = PhoneNumberTextField.text, !phonenumber.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            //signUpButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            signUpButton.isEnabled = false
            return
        }
        signUpButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signUpButton.isEnabled = true
    }

   @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    
    
    
    @IBAction func signUpBtn_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        Auth.auth().createUser(withEmail: EmailTextField.text!,password: passwordTextField.text!) { (user: AuthDataResult?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                return
            }
            let uid = Auth.auth().currentUser!.uid
            let storageRef = Storage.storage().reference(forURL: "gs://first-76cc5.appspot.com").child("ppo orofile_image").child(uid)
            if let profileImage = self.selectedImage, let imageData = profileImage.jpegData(compressionQuality: 0.1) { //imageData problem
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        ProgressHUD.dismiss()
                        return
                    }
                    let profileImageUrl = storageRef.child("profile_image") //  metadata?.downloadURL()?.absoluteString
                    profileImageUrl.downloadURL { url, error in
                        if let error = error {
                            print(error)
                            ProgressHUD.dismiss()
                        } else {
                            //NEED SOMETHING HERE
                        }
                    }
                    
                    guard let user = user?.user else { return } //HELP HERE
                    let ref = Database.database().reference()
                    let usersReference = ref.child("users")
                    let newUserReference = usersReference.child(uid)
                    newUserReference.setValue(["fullName": self.FullNameTextField.text!, "phoneNumber": self.PhoneNumberTextField.text!, "username": self.usernameTextField.text!, "email": self.EmailTextField.text!, "profileImageUrl": metadata!.path!])
                    ProgressHUD.dismiss()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LogInViewController")
                    self.present(vc!, animated: true, completion: nil)
                    print("description: \(newUserReference.description())")
                })
            }
        }
}
//    func setUserInfomation(profileImageUrl: String, username: String, email: String, id: String, fullName: String, phoneNumber:String) {
//        let ref = Database.database().reference()
//        let usersReference = ref.child("users")
//        let newUserReference = usersReference.child(id)
//        newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl])
//        self.performSegue(withIdentifier: "signUpToTabbarVC", sender: nil)
//    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
