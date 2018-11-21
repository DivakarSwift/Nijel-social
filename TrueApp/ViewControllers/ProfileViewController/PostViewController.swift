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

class PostViewController: UIViewController, YourCellDelegate {
    
    func didPressButton() {
        let database = Database.database().reference().child("posts").childByAutoId()
        if let uid = Auth.auth().currentUser?.uid {
            let db = Database.database().reference().child("users")
            db.child(uid).child("SavedPosts").child((post?.id)!).setValue(["postFromUserId" : post?.postFromUserId, "postToUserId" : post?.postToUserId, "text" : post?.text, "imgURL" : post?.imgURL, "date" : post?.date, "whoPosted" : post?.whoPosted, "isWatchedByUser" : post?.isWatchedByUser, "contentDate" : post?.contentDate])
        }
        
        let alertController = UIAlertController(title: "Success", message: "Saved", preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
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
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInsets: UIEdgeInsets
            if UIDevice.current.orientation == .portrait {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.height + 30), right: 0.0);
            } else {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.width), right: 0.0);
            }
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            viewBottomConstraint.constant = keyboardSize.height - 50
            view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
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
                cell.subscriptionLabel.text = post?.text
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
}

extension PostViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 600
//    }
}
