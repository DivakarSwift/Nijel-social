//
//  FeedTableViewCell.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/3/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import AVFoundation

protocol FeedTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId:String)
    }

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var posterLabel: UILabel!
    
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var heartLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var commentImageView: UIImageView!
    
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var likeCountButton: UIButton!
    
    @IBOutlet weak var storyLabel: UILabel!
    
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
    
    @IBOutlet weak var volumeView: UIView!
    
    @IBOutlet weak var volumeButton: UIButton!
    
    var delegate: FeedTableViewCellDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var postRef: DatabaseReference!
    
    var post: Post?{
        didSet{
            //updateView()
            //print(post?.story)
        }
    }
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    
    var isMuted = true
    
//    func updateView(){
//        storyLabel.text = post?.story
//        //print("ratio: \(post?.ratio)")
////        ratio = widthPhoto / heightPhoto
////        heightPhoto = widthPhoto / ratio
////        widthPhoto =
//        //storyLabel //NEED TIMESTAMP HERE
//        //Api.User.observeUserByUsername(username: <#T##String#>, completion: <#T##(User) -> Void#>) //ep 85 - mention user by username
//        if let ratio = post?.ratio{
//           // print("frame post Image:\(postImageView.frame)")
//            heightConstraintPhoto.constant = UIScreen.main.bounds.width / ratio
//            layoutIfNeeded()
//           // print("frame post Image:\(postImageView.frame)")
//
//        }
//        if let photoUrlString = post?.photoUrl{
//            let photoUrl = URL(string: photoUrlString)
//            postImageView.sd_setImage(with: photoUrl)
//        }
//        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString){
//            print("videoUrlString: \(videoUrlString)")
//            self.volumeView.isHidden = false
//            player = AVPlayer(url: videoUrl)
//            playerLayer = AVPlayerLayer(player: player)
//            playerLayer?.frame = postImageView.frame
//            playerLayer?.frame.size.width = UIScreen.main.bounds.width
//            playerLayer?.frame.size.height = UIScreen.main.bounds.width / post!.ratio!
//            self.contentView.layer.addSublayer(playerLayer!)
//            self.contentView.layer.zPosition = 1
//            player?.play()
//            player?.isMuted = isMuted
//        }
//        if let timestamp = post?.timestamp{
//            print(timestamp)
//            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
//            let now = Date()
//            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
//            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
//            var timeText = ""
//            if diff.second! <= 0 {
//                timeText = "Now"
//            }
//            if diff.second! > 0 && diff.minute! == 0 {
//                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
//            }
//            if diff.minute! > 0 && diff.hour! == 0{
//                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
//            }
//            if diff.hour! > 0 && diff.day! == 0{
//                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
//            }
//            if diff.day! > 0 && diff.weekOfMonth! == 0{
//                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
//            }
//            if diff.weekOfMonth! > 0 {
//                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
//            }
//            timeLabel.text = timeText
//        }
//
//        self.updateLike(post: self.post!)
//    }
    
    
    @IBAction func volumeButton_TouchUpInside(_ sender: UIButton) {
        if isMuted{
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "volume"), for: UIControl.State.normal)
        } else{
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "mute"), for: UIControl.State.normal)
        }
        player?.isMuted = isMuted
    }
    
    
//    func updateLike(post:Post){
//        let imageName = post.likes == nil || !post.isLiked! ? "Heart" : "hearts-filled"
//        likeImageView.image = UIImage(named: imageName)
//        guard let count = post.likeCount else {
//            return
//        }
//        if count != 0{
//            likeCountButton.setTitle("\(count) likes", for: UIControl.State.normal)
//        } else{
//            likeCountButton.setTitle("Be the first to like this", for: UIControl.State.normal)
//        }
//    }
    
    func setupUserInfo(){
       posterLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
             //profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "squareprofile")  ) //shouldnt need this because profile image shouldnt be on post
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        posterLabel.text = ""
        accountLabel.text = ""
        storyLabel.text = ""
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        //let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        //likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForAccountLabel = UITapGestureRecognizer(target: self, action: #selector(self.accountLabel_TouchUpInside))
        accountLabel.addGestureRecognizer(tapGestureForAccountLabel) //WAS NAMELABEL
        accountLabel.isUserInteractionEnabled = true //WAS NAMELABEL
    }
    
    @objc func accountLabel_TouchUpInside(){
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
//    @objc func likeImageView_TouchUpInside(){
//        Api.Post.incrementLikes(postId: post!.id!, onSuccess: { (post) in
//            self.updateLike(post: post)
//            self.post?.likes = post.likes
//            self.post?.isLiked = post.isLiked
//            self.post?.likeCount = post.likeCount
//            
//        }) {(errorMessage) in
//            ProgressHUD.showError(errorMessage)
//        }
//        
//        
//       // incrementLikes(forRef: postRef)
//        // postRef = Api.Post.REF_POSTS.child(post!.id!)
//    }
    
    
    
    @objc func commentImageView_TouchUpInside(){
        print("commentImageView_TouchUpInside")
        if let id = post?.id{
            delegate?.goToCommentVC(postId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        volumeView.isHidden = true
        //profileImageView.image = UIImage(named: "userprofile")
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state*/
    }

}
