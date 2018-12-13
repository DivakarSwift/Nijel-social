//
//  PostViewController.swift
//  TrueApp
//
//  Created by Stanislau Sakharchuk on 9/30/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ProgressHUD

class PostViewController: UIViewController, YourCellDelegate {
    
    func didPressButton() {
        _ = Database.database().reference().child("posts").childByAutoId()
        print("savedButton pressed")
        if let uid = Auth.auth().currentUser?.uid {
            let db = Database.database().reference().child("users").child(uid).child("SavedPosts")
            db.child((post?.id)!).observeSingleEvent(of: .value, with: {
                snapshot in
                print("snapshot.exists()")
                if snapshot.exists(){
                    db.child((self.post?.id)!).removeValue()
                    //self.saveButton.setBackgroundImage(UIImage(named: "saveicon"), for: .normal)
                    let alertController = UIAlertController(title: "Success", message: "Post removed", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.parent?.present(alertController, animated: true, completion: nil)
                    //message = "Post removed from saved images"
                }else{
                    db.child((self.post?.id)!).setValue(["postFromUserId" : self.post?.postFromUserId as Any, "postToUserId" : self.post?.postToUserId as Any, "text" : self.post?.text as Any, "imgURL" : self.post?.imgURL as Any, "date" : self.post?.date as Any, "whoPosted" : self.post?.whoPosted as Any, "isWatchedByUser" : self.post?.isWatchedByUser as Any, "contentDate" : self.post?.contentDate as Any])
                    //self.saveButton.setBackgroundImage(UIImage(named: "save"), for: .normal)
                    let alertController = UIAlertController(title: "Success", message: "Post Saved", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.parent?.present(alertController, animated: true, completion: nil)
                }
            })
            
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    var post: Post?
    var commentatorImage: UIImage?
    var postImage: UIImage?
    
    class func instantiate(post: Post, commentatorImage: UIImage, postImage: UIImage) -> PostViewController {
        let vc = StoryboardControllerProvider<PostViewController>.controller(storyboardName: "PostViewController")!
        vc.post = post
        vc.commentatorImage = commentatorImage
        vc.postImage = postImage
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CommentHeadCell", bundle: nil), forCellReuseIdentifier: "CommentHeadCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.separatorStyle = .none
        imageView.layer.cornerRadius = 8
        
        let infoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "information.png"), style: .plain, target: self, action: #selector(showMenu))
        navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc func showMenu() {
        let actionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionMenu.addAction(UIAlertAction(title: "Save Post", style: .default, handler: { _ in
            self.didPressButton()
        }))
        actionMenu.addAction(UIAlertAction(title: "Flag Post", style: .default, handler: { _ in
            ProgressHUD.show()
            Api.Post.flagPost(by: self.post!.id!) { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else {
                    let alertController = UIAlertController(title: "Completed", message: "Post has been flagged", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    ProgressHUD.dismiss()
                }
            }
        }))
        
        if post?.postFromUserId == Auth.auth().currentUser?.uid || post?.postToUserId == Auth.auth().currentUser?.uid {
            actionMenu.addAction(UIAlertAction(title: "Delete Post", style: .default, handler: { _
                in
                Api.Post.deletePost(post: self.post!)
                let alertController = UIAlertController(title: "Completed", message: "Post has been deleted", preferredStyle: UIAlertController.Style.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))

        }
        
        actionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            actionMenu.dismiss(animated: true)
        }))

        
        present(actionMenu, animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            viewBottomConstraint.constant = keyboardSize.height - 70
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        viewBottomConstraint.constant = 0
    }
    
}

extension PostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height > 50 {
            textViewHeightConstraint.constant = estimatedSize.height
        } else {
            textViewHeightConstraint.constant = 50
        }
        view.layoutIfNeeded()
    }
}

extension PostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentHeadCell") as? CommentHeadCell {
                cell.cellDelegate = self
                cell.selectionStyle = .none
                cell.topLabel.text = post?.whoPosted
                cell.timeLabel.text = getTime(from: post?.date ?? 0)
                cell.contentTextView.text = post?.text
                cell.postImage.image = postImage
                
                return cell
            }
            print("kek")
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return ((tableView.cellForRow(at: indexPath) as? CommentHeadCell)?.contentTextView.contentSize.height ?? 93) + 507
        }
    
        return  UITableView.automaticDimension

    
    }
    
    private func getTime(from timeInterval: Double) -> String {
        let time = Int(timeInterval)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)%24 //makes 12:30 am == 0:30 am
        var str = ""
        if hours > 12 {
            if minutes < 10 {
                str = "\(hours - 12):0\(minutes) pm"
            } else {
                str = "\(hours - 12):\(minutes) pm"
            }
        } else {
            if minutes < 10 {
                str = "\(hours):0\(minutes) am"
            } else {
                str = "\(hours):\(minutes) am"
            }
        }
        
        if hours == 0{
            str = "12: 0\(minutes) pm"
        }
        return str
    }
}

extension PostViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 600
//    }
}
