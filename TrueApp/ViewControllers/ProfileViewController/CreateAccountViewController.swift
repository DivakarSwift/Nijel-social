//
//  CreateAccountViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/10/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import Foundation
import ProgressHUD
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MessageUI

class CreateAccountViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var chosenProfilePicture: UIImageView!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    var uid: String?
    var selectedImage: UIImage?
    var activationCode = "not_active"
    var metadata: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullNameTextField.delegate = self
        fullNameTextField.tag = 0
        chosenProfilePicture.layer.cornerRadius = 10
        chosenProfilePicture.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(TrueHomeViewController.handleSelectProfilePicture))
        chosenProfilePicture.addGestureRecognizer(tapGesture)
        chosenProfilePicture.isUserInteractionEnabled = true
        fullNameTextField.backgroundColor = .clear
        fullNameTextField.tintColor = .black
        fullNameTextField.textColor = .black
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 23, width: 165, height: 0.6)
        bottomLayer.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        fullNameTextField.layer.addSublayer(bottomLayer)
        handleTextField()
        
    }
    @objc func handleSelectProfilePicture() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func showEmailAlert(success:@escaping (Bool)->()) {
        let alert = UIAlertController(title: "Success", message: "Do you want email this user, to activate account?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if !self.isValidEmail(testStr: textField.text!) {
                let alert = UIAlertController(title: "Warning", message: "Wrong email", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.showEmailAlert(success: { (completion) in
                        success(false)
                    })
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let email = textField.text
                self.sendEmail(email: email!, completion: { (completion) in
                    if completion {
                        success(true)
                    }
                })
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            self.chosenProfilePicture.image = UIImage(named: "squareprofile")
            self.selectedImage = nil
            self.fullNameTextField.text = nil
            success(true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendEmail(email: String, completion: @escaping (Bool)->()) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            var usersArr = [String]()
            usersArr.append(email)
            mail.setToRecipients(usersArr)
            mail.setSubject("Invited Code")
            let code = randomString(length: 8)
            mail.setMessageBody("<p>You're invited code: <b> \(code) </b> </p>", isHTML: true)
            self.activationCode = code
            present(mail, animated: true)
            completion(true)
            // CHECK MSG STATUS - IF SUCCESS - ADD TO BD
        } else {
            // show failure alert
        }
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(self.uid!)
        if result.rawValue == 0 {
            self.activationCode = "not_active"
        }
        let dict = ["fullName": self.fullNameTextField.text!, "profileImageUrl": metadata!, "activationCode": self.activationCode] as [String : Any]
        newUserReference.setValue(dict)
        print(dict)
        controller.dismiss(animated: true)
        self.chosenProfilePicture.image = UIImage(named: "squareprofile")
        self.selectedImage = nil
        self.fullNameTextField.text = nil
    }
    
    @IBAction func createUserAction(_ sender: UIButton) {
        view.endEditing(true)
        if selectedImage == nil || fullNameTextField.text?.trimmingCharacters(in: .whitespaces) == "" {
            let alertController = UIAlertController(title: "Warning", message: "Set image and name to profile", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        uid = randomString(length: 28)
       
        let storageRef = Storage.storage().reference(forURL: "gs://first-76cc5.appspot.com").child("ppo orofile_image").child(uid!)
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
                    self.metadata = metadata?.path
                    let ref = Database.database().reference()
                    let usersReference = ref.child("users")
                    let newUserReference = usersReference.child(self.uid!)
                    let name = self.fullNameTextField.text
                    
                    ProgressHUD.dismiss()
                    
                    self.showEmailAlert(success: { (completion) in
//                        if completion {
                            let dict = ["fullName": name!, "profileImageUrl": metadata!.path!, "activationCode": self.activationCode] as [String : Any]
                            newUserReference.setValue(dict)
                       // } else {
//                            let dict = ["fullName": name!, "profileImageUrl": metadata!.path!, "activationCode": "not_active"] as [String : Any]
//                            newUserReference.setValue(dict)
                       // }
                    })
                    

                    
                    

                })
        }
    }

    
    
    func downloadImages(success:@escaping (Bool)->()) {
       success(true)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // self.LogInButton.isEnabled = true
    }
    
    func handleTextField(){
        fullNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    
    @objc func textFieldDidChange(){
        guard let fullName = fullNameTextField.text, !fullName.isEmpty else {
            createButton.isEnabled = false
            return
        }
        createButton.isEnabled = true
    }
}

extension CreateAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            chosenProfilePicture.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
