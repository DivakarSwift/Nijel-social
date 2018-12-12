//
//  CreatePostViewController.swift
//  TrueApp
//
//  Created by Stanislau Sakharchuk on 9/27/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ProgressHUD

enum CreatePostViewControllerType {
    case byographyPost, notByographyPost
}

protocol CreatePostDelegate{
    func response(madePost:Bool)
}

class CreatePostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    var user: User!
    var image: UIImage?
    var type: CreatePostViewControllerType!
    var delegate: CreatePostDelegate!
    
    class func instantiate(user: User, type: CreatePostViewControllerType, parentClass: CreatePostDelegate) -> CreatePostViewController {
        let vc = StoryboardControllerProvider<CreatePostViewController>.controller(storyboardName: "CreatePostViewController")!
        vc.user = user
        print(vc.user.username as Any)
        vc.type = type
        vc.delegate = parentClass
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CreatePostTableViewCell", bundle: nil), forCellReuseIdentifier: "CreatePostTableViewCell")
        tableView.register(UINib(nibName: "DatePickerTableViewCell", bundle: nil), forCellReuseIdentifier: "DatePickerTableViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        let backButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        navigationItem.setRightBarButton(backButton, animated: true)
        print(Auth.auth().currentUser?.uid as Any)

        print(user.username as Any)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func btnClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostTableViewCell {
                cell.postImageView.contentMode = .scaleAspectFill
                cell.postImageView.image = chosenImage
                image = chosenImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgSizeValue  {
            var contentInsets: UIEdgeInsets
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.height), right: 0.0)
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func post() {
        self.delegate?.response(madePost: true)
        guard let textViewCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostTableViewCell else {
            return
        }
        let postTitle = textViewCell.textView.text.trimmingCharacters(in: .whitespaces)
        if  type == .notByographyPost && (image == nil || postTitle == "Story Behind Post: ") {
            let alertController = UIAlertController(title: "Warning", message: "Add image and story to your post", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        } else if type == .byographyPost && postTitle == "" {
            let alertController = UIAlertController(title: "Warning", message: "Tell the Story", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
        } else if type == .byographyPost { //|| .notByographyPost
            ProgressHUD.show()
            let database = Database.database().reference().child("posts").childByAutoId()
            if let uid = Auth.auth().currentUser?.uid {
                if let key = database.key {
                    if (self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostTableViewCell) != nil {
                                let db = Database.database().reference().child("users")
                                
                                let cellq = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DatePickerTableViewCell
                                let date  = cellq?.datePicker.date.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                                db.child(self.user.id!).child("myPosts").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(postTitle)", "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : true, "contentDate" : date])
                                db.child(self.user.id!).child("IPosted").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(postTitle)", "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : true, "contentDate" : date])
                                print(uid)
                                print(self.user.id!)
                                db.child(uid).child("IPosted").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(postTitle)", "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : true, "contentDate" : date])
                            }
                            ProgressHUD.dismiss()
                            self.navigationController?.popViewController(animated: true)
                    }
                }
            return
        }
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
                            
                            let cellq = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DatePickerTableViewCell

                            let date  = cellq?.datePicker.date.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                            print(date)
                            db.child(self.user.id!).child("myPosts").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : false, "contentDate" : date])
                            db.child(self.user.id!).child("IPosted").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : false, "contentDate" : date])
                            db.child(uid).child("IPosted").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : false, "contentDate" : date])
                            db.child(uid).child("myPosts").child(key).setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970), "whoPosted" : App.shared.currentUser.fullName!, "isWatchedByUser" : false, "contentDate" : date])
                            //database.setValue(["postFromUserId" : uid, "postToUserId" : self.user.id!, "text" : "\(cell.textView.text ?? "")", "imgURL" : metadata!.path!, "date" : (Date().timeIntervalSince1970)])
                        }
                        ProgressHUD.dismiss()
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.response(madePost: true)
                    })
                }
            }
        }
    }
}

extension CreatePostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == .notByographyPost{
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CreatePostTableViewCell") as? CreatePostTableViewCell {
                cell.completion = btnClicked
                
                if type == .byographyPost {
                    cell.addPhotoFromGaleryButton.isHidden = true
                }
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerTableViewCell") {
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension CreatePostViewController: UITableViewDelegate {
    
}
