//
//  CreateViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/29/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import ProgressHUD
import AVFoundation

class CreateViewController: UIViewController {
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    @IBOutlet weak var writingImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBAction func photoVIdeoButton(_ sender: UIButton) {
    }
    
    @IBAction func writingButton(_ sender: UIButton) {
    }
    
    @IBAction func newPageButton(_ sender: UIButton) {
    }
    
    @IBAction func captureButton(_ sender: UIButton) {
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
//        let imagePickerController = ImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.imageLimit = 10
//        present(imagePickerController, animated: true, completion: nil)
    }
    
    var selectedImage : UIImage?
    var videoUrl : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
//        print("wrapper")
//    }
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
//        guard let image = images.first else{
//            dismiss(animated: true, completion: nil)
//            return
//        }
//        selectedImage = image
//        photoImageView.image = image
//        dismiss(animated: true, completion: {
//            self.performSegue(withIdentifier: "readyToPost_Segue", sender: nil)
//        })
//    }
//        ProgressHUD.show("Waiting...", interaction: false)
//        if let imageData = UIImageJPEGRepresentation(profileImageView, 0.1){
//            let ratio = profileImageView.size.width / profileImageView.size.height
//            HelperService.uploadDataToServer(data: imageData, videoUrl: nil, ratio: ratio, story: "") {
//                self.dismiss(animated: true, completion: nil)
//                self.loadPosts()
     //want to select photos and then go to ready to post

//    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
//        print("cancel")
//        dismiss(animated: true, completion: {
//        })
//    }
    
 
    
    
   
}
