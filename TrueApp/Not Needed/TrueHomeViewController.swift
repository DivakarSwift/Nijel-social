//
//  TrueHomeViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 8/31/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class TrueHomeViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    var selectedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.layer.cornerRadius = 10
        profilePicture.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(TrueHomeViewController.handleSelectProfilePicture))
        profilePicture.addGestureRecognizer(tapGesture)
        profilePicture.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    @objc func handleSelectProfilePicture(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
    }
}

extension TrueHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profilePicture.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
