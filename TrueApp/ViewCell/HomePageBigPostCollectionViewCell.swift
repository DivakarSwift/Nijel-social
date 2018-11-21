//
//  HomePageBigPostTableViewCell.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 10/2/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class HomePageBigPostCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topHeartButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var bottomHeartButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    @IBAction func topHeartButtonPressed(_ sender: UIButton) {
    }
    @IBAction func commentButtonPressed(_ sender: UIButton) {
    }
    @IBAction func shareButtonPressed(_ sender: UIButton) {
    }
    @IBAction func bottomHeartButtonPressed(_ sender: UIButton) {
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let database = Database.database().reference().child("posts").childByAutoId()
        if let uid = Auth.auth().currentUser?.uid {
                let db = Database.database().reference().child("users")
                db.child(uid).child("SavedPosts").child((post?.id)!).setValue(["postFromUserId" : post?.postFromUserId, "postToUserId" : post?.postToUserId, "text" : post?.text, "imgURL" : post?.imgURL, "date" : post?.date, "whoPosted" : post?.whoPosted, "isWatchedByUser" : post?.isWatchedByUser, "contentDate" : post?.contentDate])
        }
        
        let alertController = UIAlertController(title: "Success", message: "Saved", preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        parentViewController?.present(alertController, animated: true, completion: nil)
        //else{
            //removefromSavedPosts
        //}
    }
    
    var post: Post?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        let storage = Storage.storage()
        if let url = post?.imgURL {
            let spaceRef = storage.reference(forURL: "gs://first-76cc5.appspot.com/\(url)")
            spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = data else { return }
                self?.postImageView.image = UIImage(data: data)
                self?.post?.image = UIImage(data: data)
            }
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as? UIViewController
            }
        }
        return nil
    }
}
