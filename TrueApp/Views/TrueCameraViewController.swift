//
//  TrueCameraViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/1/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class TrueCameraViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    
    var selectedImage: UIImage?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true

        // Do any additional setup after loading the view.
    }
    @objc func handleSelectPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }

   
}
extension TrueCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
