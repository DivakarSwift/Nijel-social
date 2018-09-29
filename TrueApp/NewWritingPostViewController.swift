//
//  NewWritingPostViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 8/31/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
import FirebaseDatabase

class NewWritingPostViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView! //maybe not
    
    @IBOutlet weak var DatePicker: UILabel!
    
    @IBOutlet weak var storyTextView: UITextView!
    
    @IBOutlet weak var postButton: UIButton!
    
    //something (Search Bar) for adding right people to story
    
    var story: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
//    func handlePost(){
//        if selectedImage != nil{
//            self.shareButton.isEnabled = true
//            self.removeButton.isEnabled = true
//            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        }
//        else{
//            self.shareButton.isEnabled = false
//            self.shareButton.backgroundColor = .lightGray
//        }
//    }
//
    
    func handleStory(){ //THIS SHOULD BE IF TEXT FIELD != nil
        if story != nil{ //""
            self.postButton.isEnabled = true
            self.postButton.backgroundColor = .black
        }
        else{
            self.postButton.isEnabled = false
            self.postButton.backgroundColor = .lightGray
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func postButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        //        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 1) {
        //            let ratio = profileImg.size.width / profileImg.size.height
        //HelperService.uploadDataToServer(story: storyTextView.text!, onSuccess: {
        //self.clean()
        self.tabBarController?.selectedIndex = 0
    }                        
}
    
    
    func sendDataToDatabase(photoUrl: String){
        let ref = Database.database().reference()
        let postsReference = ref.child("posts")
        let newPostId = postsReference.childByAutoId().key
        let newPostReference = postsReference.child(newPostId ?? "")
        guard let currentUser = Auth.auth().currentUser else{
            return
        }
        let currentUserId = currentUser.uid
//        newPostReference.setValue((["uid": currentUserId, "photoUrl":photoUrl, "caption": captionTextView.text!]), withCompletionBlock: {
//            (error, ref) in
//            if error != nil{
//                ProgressHUD.showError(error!.localizedDescription)
//                return
//            }
            let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId ?? "")
            myPostRef.setValue(true, withCompletionBlock: {(error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
//            self.clean()
//            self.tabBarController?.selectedIndex = 0
        }



