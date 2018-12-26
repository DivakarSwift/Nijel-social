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
import FirebaseDatabase

protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
    func updateUserPostsView(changedInfo:Bool)
}



class SettingTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var isExclusiveSwitch: UISwitch!
    @IBOutlet weak var attachButton: UIButton!
    
    struct Constants {
        enum Rows: Int {
            case deleteAccount = 11
            case deactivateAccount = 10
        }
    }
    
    
    var delegate: SettingTableViewControllerDelegate?
    var isImageChanged = false
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        usernameTextField.delegate = self
        profileImageView.clipsToBounds = true
        emailTextField.delegate = self
        fullNameTextField.delegate = self
        phoneNumberTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(){
        ProgressHUD.show()
        Api.User.observeCurrentUser { [weak self] (user) in
            guard let `self` = self else { return }
            self.user = user
            self.fullNameTextField.text = user.fullName //ERROR
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            self.phoneNumberTextField.text = user.phoneNumber
            self.isExclusiveSwitch.isOn = user.isExclusive ?? false
            self.attachButton.isHidden = user.phoneNumber == Auth.auth().currentUser?.phoneNumber
            let storage = Storage.storage()
            let spaceRef = storage.reference(forURL: "\(Config.STORAGE_ROOT_REF)\(user.profileImageUrl!)")
            spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
                guard let `self` = self else { return }
                ProgressHUD.dismiss()
                if let error = error {
                    print(error.localizedDescription)
                    return
                } //if user has switched exclusive from off to on, have alert
                guard let data = data else { return }
                self.profileImageView.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        self.delegate?.updateUserPostsView(changedInfo: true)
        var imageData: Data? = nil
        if (usernameTextField.text?.count)! > 15{ //or if username is already is use by someone else
            let alertController = UIAlertController(title: "Warning", message: "Limit username to 15 characters", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        //if email is changed to an email that is alredy in use, alert. "Email is already in use, use another"
        if isImageChanged, let profileImg = self.profileImageView.image {
           imageData = profileImg.jpegData(compressionQuality: 0.1)
        }
        ProgressHUD.show("Waiting...")
        AuthServiceViewController.updateUserInfo(username: usernameTextField.text!,
                                                 email: emailTextField.text!,
                                                 imageData: imageData,
                                                 phoneNumber: phoneNumberTextField.text!,
                                                 fullName: fullNameTextField.text!,
                                                 isExclusive: isExclusiveSwitch.isOn,
                                                 onSuccess: {
                                                    ProgressHUD.showSuccess("Success")
                                                    self.delegate?.updateUserInfo()
                                                }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
                                                    self.delegate?.updateUserPostsView(changedInfo: true)
        }
        //tableView.reloadData()
    }
    

    
    
    @IBAction func LogOutButton_TouchUpInside(_ sender: Any) {
        try! Auth.auth().signOut()
        showLaunchScreen()
    }
    
    @IBAction func changeProfileButton_TouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case Constants.Rows.deleteAccount.rawValue:
            deleteAccount()
        case Constants.Rows.deactivateAccount.rawValue:
            deactivateAccount()
            print("shouldDeactivate") //not showing up
        default:
            break
        }
    }
    
    func deleteAccount() {
        //ProgressHUD.show()
        let alertController = UIAlertController(title: "Delete Account", message: "Are you sure? This will delete all information, with no way of retrieving it.", preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: { action in self.deleteAccountHelper()})
        let secondAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(secondAction)
        self.present(alertController, animated: true, completion: nil)
        ProgressHUD.dismiss()
        
    } //fix
    
    func deleteAccountHelper(){
        print("Account deletion")
        Api.User.REF_CURRENT_USER?.removeValue () { error, _ in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            Auth.auth().currentUser?.delete() { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                ProgressHUD.dismiss()
                self.showLaunchScreen()
                let alertController = UIAlertController(title: "Message", message: "Account has been deleted", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
    }
    func deactivateAccount() {
        //ProgressHUD.show()
        let alertController = UIAlertController(title: "Deactivate Account", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: { action in self.deactivateAccountHelper()})
        let secondAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(secondAction)
        self.present(alertController, animated: true, completion: nil)
        ProgressHUD.dismiss()
    }
    
    func deactivateAccountHelper(){
        print("account has been deactivated")
        let dict = ["deactivated": true]
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
            } else {
                ProgressHUD.dismiss()
                try! Auth.auth().signOut()
                self.showLaunchScreen()
                let alertController = UIAlertController(title: "Message", message: "Account has been deactivated", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
        })
    }
    
    @IBAction func attachButtonTouched(_ sender: Any) {
        let vc = VerifyPhoneViewController.instantiate()
        vc.nextViewController = .settings
        present(vc, animated: true)
    }
    

    func showLaunchScreen() {
        let vc = LaunchScreenViewController.instantiate()
        self.present(vc, animated: false, completion: nil)
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
