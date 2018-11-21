//
//  SettingTableViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/8/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth

protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate: SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        fullNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        fetchCurrentUser()
    }
    func fetchCurrentUser(){
        Api.User.observeCurrentUser { (user) in
            self.fullNameTextField.text = user.fullName //ERROR
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            self.phoneNumberTextField.text = user.phoneNumber
//            if let profileUrl = URL(string: user.profileImageUrl!){
//                self.profileImageView.sd_setImage(with: profileUrl)
//            }
        }
    }
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        if let profileImg = self.profileImageView.image, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            ProgressHUD.show("Waiting...")
            AuthServiceViewController.updateUserInfo(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, phoneNumber: phoneNumberTextField.text!, fullName: fullNameTextField.text!, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfo()
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            }
        }
    }
    

        
    
    @IBAction func LogOutButton_TouchUpInside(_ sender: Any) {
        try! Auth.auth().signOut()
        let vc = LaunchScreenViewController.instantiate()
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func changeProfileButton_TouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}

extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

extension SettingTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        textField.resignFirstResponder()
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
