//
//  CreatePostViewController.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 9/27/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ProgressHUD

class CreatePostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    var user: User!
    var image: UIImage?
    
    class func instantiate(user: User) -> CreatePostViewController {
        let vc = StoryboardControllerProvider<CreatePostViewController>.controller(storyboardName: "CreatePostViewController")!
        vc.user = user
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CreatePostTableViewCell", bundle: nil), forCellReuseIdentifier: "CreatePostTableViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let backButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        navigationItem.setRightBarButton(backButton, animated: true)
    }
    
    func btnClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostTableViewCell {
                cell.postImageView.contentMode = .scaleAspectFit
                cell.postImageView.image = chosenImage
                image = chosenImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgSizeValue  {
            var contentInsets: UIEdgeInsets
            if UIDevice.current.orientation == .portrait {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.height), right: 0.0);
            } else {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.width), right: 0.0);
            }
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func post() {
        ProgressHUD.show()
        let database = Database.database().reference().child("posts").childByAutoId()
        if let uid = Auth.auth().currentUser?.uid {
            if let key = database.key {
                let storageRef = Storage.storage().reference(forURL: "gs://first-76cc5.appspot.com").child("postImages").child(key)
                if let profileImage = self.image, let imageData = profileImage.jpegData(compressionQuality: 0.1) {
                    storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            ProgressHUD.dismiss()
                            return
                        }
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostTableViewCell {
                            let db = Database.database().reference().child("users")
                            db.child(self.user.id!).child("myPosts").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970)])
                            db.child(self.user.id!).child("IPosted").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970)])
                            //database.setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970)])
                        }
                        ProgressHUD.dismiss()
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
}

extension CreatePostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CreatePostTableViewCell") as? CreatePostTableViewCell {
            cell.completion = btnClicked
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
}

extension CreatePostViewController: UITableViewDelegate {
    
}
