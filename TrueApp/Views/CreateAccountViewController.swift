//
//  CreateAccountViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/10/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var chosenProfilePicture: UIImageView!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    var selectedImage: UIImage?
    
    
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
    @objc func handleSelectProfilePicture(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
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
        fullNameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            chosenProfilePicture.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

