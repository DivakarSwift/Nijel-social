//
//  PeopleTableViewCell.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/6/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseStorage

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var user: User?
    var activityIndicator: UIActivityIndicatorView!
    
    func updateView(user: User) {
        self.user = user
        setUpUI()
        setImage()
    }
    
    func setImage() {
        let storage = Storage.storage()
        if let urlString = user?.profileImageUrl {
            let spaceRef = storage.reference(forURL: "gs://first-76cc5.appspot.com/\(urlString)")
            spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
                if error != nil {
                    print(error!.localizedDescription)
                    self?.activityIndicator.stopAnimating()
                    return
                }
                guard let data = data else { return }
                self?.profileImage.image = UIImage(data: data)
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    func setUpUI() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: profileImage.frame.width/4, y: profileImage.frame.height/4, width: profileImage.frame.width/2, height: profileImage.frame.height/2))
        nameLabel.text = user?.username
        activityIndicator.style = .gray
        activityIndicator.hidesWhenStopped = true
        profileImage.layer.cornerRadius = 8
        profileImage.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //        if user!.isFollowing! {
        //            configureUnFollowButton()
        //        }else{
        //            configureFollowButton()
        //
        //        }
    }
    
    func configureFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        followButton.setTitle("Follow", for: UIControl.State.normal)
        //followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    func configureUnFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Following", for: UIControl.State.normal)
       // followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
//    @objc func followAction(){
//        if user!.isFollowing! == false{
//            Api.Follow.followAction(withUser: user!.id!)
//            configureUnFollowButton()
//            user!.isFollowing! = true
//        }
//    }
//
//    @objc func unFollowAction(){
//        if user!.isFollowing == true{
//            Api.Follow.unFollowAction(withUser: user!.id!)
//            configureFollowButton()
//            user!.isFollowing = false
//        }
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
