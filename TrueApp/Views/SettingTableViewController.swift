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
import FirebaseStorage

protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate: SettingTableViewControllerDelegate?
    var isImageChanged = false
    
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
        ProgressHUD.show()
        Api.User.observeCurrentUser { [weak self] (user) in
            guard let `self` = self else { return }
            self.fullNameTextField.text = user.fullName //ERROR
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            self.phoneNumberTextField.text = user.phoneNumber
            let storage = Storage.storage()
            let spaceRef = storage.reference(forURL: "\(Config.STORAGE_ROOT_REF)\(user.profileImageUrl!)")
            spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
                guard let `self` = self else { return }
                ProgressHUD.dismiss()
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let data = data else { return }
                self.profileImageView.image = UIImage(data: data)
            }
        }
    }
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        var imageData: Data? = nil
        if isImageChanged, let profileImg = self.profileImageView.image {
           imageData = profileImg.jpegData(compressionQuality: 0.1)
        }
        ProgressHUD.show("Waiting...")
        AuthServiceViewController.updateUserInfo(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, phoneNumber: phoneNumberTextField.text!, fullName: fullNameTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.delegate?.updateUserInfo()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
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
            isImageChanged = true
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
