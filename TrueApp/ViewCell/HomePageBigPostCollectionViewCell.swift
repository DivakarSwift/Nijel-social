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
import ProgressHUD
import AVFoundation

protocol HomePageBigPostCollectionViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId:String)
}

class HomePageBigPostCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var breakLineView: UIView!
    
 
    @IBAction func commentButtonPressed(_ sender: UIButton) {
    }
    
    
  
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        _ = Database.database().reference().child("posts").childByAutoId()
       print("savedButton pressed")
        if let uid = Auth.auth().currentUser?.uid {
            let db = Database.database().reference().child("users").child(uid).child("SavedPosts")
            db.child((post?.id)!).observeSingleEvent(of: .value, with: {
                snapshot in
                print("snapshot.exists()")
                if snapshot.exists(){
                    db.child((self.post?.id)!).removeValue()
                    self.saveButton.setBackgroundImage(UIImage(named: "saveicon"), for: .normal)
                    let alertController = UIAlertController(title: "Success", message: "Post removed", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.parentViewController?.present(alertController, animated: true, completion: nil)
                    //message = "Post removed from saved images"
                }else{
                    db.child((self.post?.id)!).setValue(["postFromUserId" : self.post?.postFromUserId as Any, "postToUserId" : self.post?.postToUserId as Any, "text" : self.post?.text as Any, "imgURL" : self.post?.imgURL as Any, "date" : self.post?.date as Any, "whoPosted" : self.post?.whoPosted as Any, "isWatchedByUser" : self.post?.isWatchedByUser as Any, "contentDate" : self.post?.contentDate as Any])
                    self.saveButton.setBackgroundImage(UIImage(named: "save"), for: .normal)
                    let alertController = UIAlertController(title: "Success", message: "Post Saved", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.parentViewController?.present(alertController, animated: true, completion: nil)
                }
            })
           
        }
    }
    var delegate: HomePageBigPostCollectionViewCellDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var postRef: DatabaseReference!
    
    var post: Post?{
        didSet{
            updateView()
        }
    }
    
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    
    var isMuted = true
    
    
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
    
    
    func setupUserInfo(){
        topLabel.text = user?.fullName
        if let photoUrlString = user?.profileImageUrl{
            _ = URL(string: photoUrlString)
            //profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "squareprofile")  ) //shouldnt need this because profile image shouldnt be on post
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        topLabel.text = ""
        storyLabel.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentButton.addGestureRecognizer(tapGesture)
        commentButton.isUserInteractionEnabled = true
        print("fuck magnum")
        
        
        let tapGestureForAccountLabel = UITapGestureRecognizer(target: self, action: #selector(self.accountLabel_TouchUpInside))
        topLabel.addGestureRecognizer(tapGestureForAccountLabel)
        topLabel.isUserInteractionEnabled = true
        //commentLabel.addGestureRecognizer(tapGesture)
        //commentLabel.isUserInteractionEnabled = true
        print("top lavel is yeet af")
        
        
    }
    
    @objc func accountLabel_TouchUpInside(){
        print("user should go to account")
        if let id = post?.postFromUserId {
            print("accountLabel_TouchUpInside")
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    @objc func commentImageView_TouchUpInside(){
        print("commentImageView_TouchUpInside")
        if let id = post?.id{
            print("jayyosi sucks")
            print(delegate as Any) //is nil for some reason
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //volumeView.isHidden = true
        //profileImageView.image = UIImage(named: "userprofile")
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    
    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state*/
    //    }
    
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
