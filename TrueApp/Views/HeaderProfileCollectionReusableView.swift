//
//  HeaderProfileCollectionReusableView.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/5/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth


protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
}

protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    func goToSettingVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView, UITextFieldDelegate{
    
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
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
    var selectedImage: UIImage?
    var user:User?{
        didSet{
            updateView()
        }
    }
    
     func viewDidLoad() {
        //super.viewDidLoad()
        profileImage.layer.cornerRadius = 10
        profileImage.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(HeaderProfileCollectionReusableView.handleSelectProfilePicture))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.cornerRadius = 10
        profileImage.clipsToBounds = true
        userBio.delegate = self
        userBio.tag = 0


    }
    
    
    @objc func handleSelectProfilePicture(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //clear()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // view.endEditing(true) //would make it so i could touch out of text field and keyboard will disappear
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
    
    func updateView(){
        self.nameLabel.text = user!.fullName
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
            //nameLabel.text = user?.fullName

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
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil){
        //DONT KNOW TRYING TO SELECT PROF IMAGE
    }
    
    func dismiss(animated flag: Bool,
                 completion: (() -> Void)? = nil){ //DONT KNOW IF RIGHT
        
    }

} //EXTENSION FOR SELECTE|ING PROF IMAGE
extension HeaderProfileCollectionReusableView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}


