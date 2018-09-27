//
//  HomeViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/29/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol HomeViewControllerDelegate {
    func updateFollowButton(forUser user: User)
}

protocol HomeViewControllerDelegateSwitchSettingVC {
    func goToSettingVC()
}

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var myPostsCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var subTextProfileLabel: UILabel!
    
    @IBOutlet weak var userBio: UITextField!
    
    @IBOutlet weak var userHomeButton: UIButton!
    
    @IBOutlet weak var userPostsButton: UIButton!
    
    @IBOutlet weak var lifeStoryLabel: UILabel!
    
    @IBOutlet weak var storyUpToNowLabel: UILabel!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
    var user:User?{
        didSet{
            updateView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 10
        profileImage.clipsToBounds = true
        userBio.delegate = self
        userBio.tag = 0
    }
    
//    @objc func handleSelectProfilePicture(){
//        let pickerController = UIImagePickerController()
//        pickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
//        present(pickerController, animated: true , completion: nil)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //clear()
    }
    
    func updateView(){
        self.nameLabel.text = user!.fullName //THIS ISNT WORKING
        nameLabel.textColor = UIColor.black
        userBio.textColor = UIColor.black
        subTextProfileLabel.textColor = .black
        if let photoUrlString = user!.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
        Api.MyPosts.fetchCountMyPosts(userId: user!.id!) { (count) in
            self.myPostsCountLabel.text = "\(count)"
        }
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowers(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        if user?.id == Auth.auth().currentUser!.uid{
            followButton.setTitle("Edit Profile", for: UIControlState.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControlEvents.touchUpInside)
            
        }else{
            updateStateFollowButton()
        }
    }
    
    func clear(){
        self.nameLabel.text = ""
        self.myPostsCountLabel.text = ""
        self.followingCountLabel.text = ""
        self.followersCountLabel.text = ""
    }
    
    @objc func goToSettingVC(){
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton(){
        if user!.isFollowing! {
            configureUnFollowButton()
        }else{
            configureFollowButton()
            
        }
    }
    
    func configureFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
    }
    func configureUnFollowButton(){
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControlEvents.touchUpInside)
    }
    
    @objc func followAction(){
        if user!.isFollowing! == false{
            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user!.isFollowing! = true
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    @objc func unFollowAction(){
        if user!.isFollowing == true{
            Api.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
            delegate?.updateFollowButton(forUser: user!)
            
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}




