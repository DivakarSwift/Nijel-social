//
//  ReadyToPostViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/1/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseStorage
import ProgressHUD
import FirebaseDatabase
import FirebaseAuth
import AVFoundation

class ReadyToPostViewController: UIViewController {

    @IBOutlet weak var removeButton: UIButton!//should be bar button item
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var videoUrl : URL?
    var selectedImage : UIImage?
    var story: UITextField?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true


        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    func handlePost(){
        if selectedImage != nil{
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        else{
            self.shareButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
    }
    func handleStory(){ //THIS SHOULD BE IF TEXT FIELD != nil
        if selectedImage != nil{
            self.shareButton.isEnabled = true
            self.shareButton.backgroundColor = .red
        }
        else{
            self.shareButton.isEnabled = false
            self.shareButton.backgroundColor = .blue
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"] //ALSO WANT WRITING POSTS
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = profileImg.jpegData(compressionQuality: 1) {
            let ratio = profileImg.size.width / profileImg.size.height
            HelperService.uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio: ratio,  story: captionTextView.text!, onSuccess: {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            })
        }
        else{
            ProgressHUD.showError("Photo can only be empty on a writing post.")
        }
        
//     let photoIdString = NSUUID().uuidString
//        print(photoIdString)
//     let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
//     storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
//     if error != nil {
//        ProgressHUD.showError(error!.localizedDescription)
//        return
//     }
//     let photoUrl = metadata?.downloadURL()?.absoluteString //ERRORERRORERROR
//        self.sendDataToDatabase(photoUrl: photoUrl!)
     
 } //METHOD WOULD PUT POSTS IN DATABASE

    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }

    func sendDataToDatabase(photoUrl: String){
        let ref = Database.database().reference()
        let postsReference = ref.child("posts")
        let newPostId = postsReference.childByAutoId().key
        let newPostReference = postsReference.child(newPostId)
        guard let currentUser = Auth.auth().currentUser else{
            return
        }
        let currentUserId = currentUser.uid
        newPostReference.setValue((["uid": currentUserId, "photoUrl":photoUrl, "caption": captionTextView.text!]), withCompletionBlock: {
            (error, ref) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostRef.setValue(true, withCompletionBlock: {(error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            self.clean()
            self.tabBarController?.selectedIndex = 0
        })
    }

    func clean(){
        self.captionTextView.text = "Story Behind Post: " //if post is picture "story behind picture: ", same with video
        self.photo.image = UIImage(named: "placeholder")
        self.selectedImage = nil
    }
}
extension ReadyToPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        print("did Finish Picking Media")
        print(info)
        
        if let videoUrl = ["UIImagePickerControllerMediaUrl"] as? URL {
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl){
                selectedImage = thumbnailImage
                photo.image = thumbnailImage
                self.videoUrl = videoUrl
            }
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
}
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 7, timescale: 1), actualTime: nil) //ACTUAL TIME might be needed to get the time when video was taken
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        return nil
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
