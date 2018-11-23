//
//  HeaderProfileCollectionReusableView.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/5/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
    func goToSettingVC()
    func showDateFilter()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var editBioButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bornTextView: UITextView!
    @IBOutlet weak var schoolTextView: UITextView!
    @IBOutlet weak var relativesTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userDateField: UITextField!
    @IBOutlet weak var textViewBio: UITextView!
    @IBOutlet weak var activateButton: UIButton!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var toLifeStorySection: UIButton!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var dateFilterButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?

    var selectedImage: UIImage?
    var editProfile = false
    var isFilteredByDate = false
    var editableState = false {
        didSet {
            if editableState {
                textViewBio.isUserInteractionEnabled = true
                editBioButton.setTitle("Save", for: .normal)
            } else {
                textViewBio.isUserInteractionEnabled = false
                editBioButton.setTitle("Edit", for: .normal)
                updateUserBio(with: textViewBio.text)
            }
        }
    }
    
    var user: User? {
        didSet{
            updateView()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func switchsegment(_ sender: Any) {
        if segmentControll.selectedSegmentIndex == 0 {
            postsCountLabel.isHidden = true
            dateFilterButton.isHidden = true
            toLifeStorySection.isHidden = false
        } else {
            postsCountLabel.isHidden = false
            dateFilterButton.isHidden = false
            toLifeStorySection.isHidden = true
        }
    }
    
    @IBAction func editProfileAction(_ sender: UIButton) {
        if editProfile {
            bornTextView.isUserInteractionEnabled = false
            relativesTextView.isUserInteractionEnabled = false
            schoolTextView.isUserInteractionEnabled = false
            editProfileButton.setTitle("Edit", for: .normal)
            textViewBio.resignFirstResponder()
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["born" : bornTextView.text])
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["relatives" : relativesTextView.text])
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["school" : schoolTextView.text])
            editProfile = false
        } else {
            bornTextView.isUserInteractionEnabled = true
            relativesTextView.isUserInteractionEnabled = true
            schoolTextView.isUserInteractionEnabled = true
            editProfileButton.setTitle("Save", for: .normal)
            editProfile = true
        }
    }
    
    @IBAction func editBioAction(_ sender: UIButton) {
        editableState = !editableState
    }
    
    @IBAction func editDateAction(_ sender: UITextField) {
        Database.database().reference().child("users").child(user!.id!).updateChildValues(["userDate" : userDateField.text as Any])
    }
    
    @IBAction func filterByDateButtonTouched(_ sender: Any) {
        delegate?.showDateFilter()
    }
    

    func viewDidLoad() {
        profileImage.layer.cornerRadius = 10
        profileImage.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(HeaderProfileCollectionReusableView.handleSelectProfilePicture))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.cornerRadius = 10
        userDateField.delegate = self
        textViewBio.delegate = self
        profileImage.clipsToBounds = true
        textViewBio.text = "Introduction"
        textViewBio.textColor = UIColor.lightGray
    }
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (Auth.auth().currentUser?.uid != user?.id) {
            if range.length == 10 && textViewBio.text.count >= 0 {
                return false
            }
        }
        
        if text.count > 0 && textView === textViewBio {
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.lightGray])
            textView.textStorage.insert(attributedString, at: range.location)
            let cursor = NSRange(location: textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

    }
    
    func textViewDidEndEditing(_ textView: UITextView) { //only works if you click in, then out of hte text view

    }
 
    func getUser(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let code = dict["activationCode"] as? String else { return }
            if code != "activated" {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateUserBio(with bio: String) {
        Database.database().reference().child("users").child(user!.id!).updateChildValues(["bio" : bio])
        Database.database().reference().child("users").child(user!.id!).child("bio_edits").childByAutoId().updateChildValues(["user_id": Auth.auth().currentUser!.uid, "time": Date().timeIntervalSince1970])
    }
  
    @objc func handleSelectProfilePicture() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true , completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    
    
    func getBio(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let bio = dict["bio"] as? String else { return }
            self.textViewBio.text = bio
            if let bio_edits = dict["bio_edits"] as?  [String: [String: Any]] {
                let filteredDates = bio_edits.filter { item in
                    if let timeFrom =  item.value["time"] as? TimeInterval {
                        return (Date().timeIntervalSince1970 - timeFrom) / 60 / 60 < 24
                    }
                    return false
                }
                if filteredDates.count > 0 {
                    let attributedText = NSAttributedString(string: self.textViewBio.text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.red])
                    self.textViewBio.attributedText = attributedText
                }
            }
            
            completion(true)
        }
    }
    
    func getBornDate(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let born = dict["born"] as? String else { return }
            self.bornTextView.text = born
            completion(true)
        }
    }
    func getRelatives(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let relatives = dict["relatives"] as? String else { return }
            self.relativesTextView.text = relatives
            completion(true)
        }
    }
    func getSchool(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let school = dict["school"] as? String else { return }
            self.schoolTextView.text = school
            completion(true)
        }
    }
    
    
    func getUserDate(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let userDate = dict["userDate"] as? String else { return }
            self.userDateField.text = userDate
            completion(true)
        }
    }
    
    func updateView() {
        self.nameLabel.text = user!.fullName
        self.textViewBio.delegate = self
        self.bornTextView.sizeToFit()
        self.bornTextView.layoutIfNeeded()
        let contentSize = self.bornTextView.sizeThatFits(self.bornTextView.bounds.size)
        self.relativesTextView.sizeToFit()
        self.relativesTextView.layoutIfNeeded()
        _ = self.relativesTextView.sizeThatFits(self.relativesTextView.bounds.size)
        self.schoolTextView.sizeToFit()
        self.schoolTextView.layoutIfNeeded()
        _ = self.schoolTextView.sizeThatFits(self.schoolTextView.bounds.size)
        _ = contentSize.height
        nameLabel.textColor = UIColor.black
        hideKeyboard()
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImage.sd_setImage(with: photoUrl)
        }
        
        Api.MyPosts.fetchCountMyPosts(userId: user!.id!) {  (count) in
            self.myPostsCountLabel.text = "\(count)"
            print(self.user?.myPosts?.count as Any)
        }
        Api.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        Api.Follow.fetchCountFollowers(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        bornTextView.isUserInteractionEnabled = false
        relativesTextView.isUserInteractionEnabled = false
        schoolTextView.isUserInteractionEnabled = false
        if user?.id == Auth.auth().currentUser!.uid {
            userDateField.isUserInteractionEnabled = true
            followButton.setTitle("Edit Profile", for: UIControl.State.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControl.Event.touchUpInside)
        } else {
            userDateField.isUserInteractionEnabled = false
            updateStateFollowButton()
        }

        if user?.IPosted == nil{
            filterSwitch.isHidden = true
        }
        else{
            filterSwitch.isHidden = false
        }
        
        if user?.id != Auth.auth().currentUser?.uid {
            segmentControll.setTitle("Posts", forSegmentAt: 1)
        } else {
            segmentControll.setTitle("Your Posts", forSegmentAt: 1)
        }
        getBio { (completion) in }
        getUserDate { (completion) in }
        
        getSchool { (completion) in }
        getRelatives { (completion) in }
        getBornDate { (completion) in }
        getUser { (completion) in
            if completion {
                self.activateButton.isHidden = false
            } else {
                self.activateButton.isHidden = true
            }
        }
        
    }
    
    func clear(){
        self.nameLabel.text = ""
        self.myPostsCountLabel.text = ""
        self.followingCountLabel.text = ""
        self.followersCountLabel.text = ""
    }
    
    @objc func goToSettingVC() {
        delegate?.goToSettingVC()
    }
    
    func updateStateFollowButton(){
        if user?.id == Auth.auth().currentUser!.uid{
            followButton.setTitle("Edit Profile", for: UIControl.State.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControl.Event.touchUpInside)
            return
        }
        Api.Follow.isFollowing(userId: user!.id!) { isFollowing in
            if isFollowing == true {
                self.configureUnFollowButton()
            } else {
                self.configureFollowButton()
            }
        }

//        if user?.followerSet == true {
//            configureUnFollowButton()
//        }else{
//            configureFollowButton()
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
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor.clear
        followButton.setTitle("Following", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {        
        Api.Follow.followAction(withUser: user!.id!)
        configureUnFollowButton()
    }
    
    @objc func unFollowAction() {
        Api.Follow.unFollowAction(withUser: user!.id!)
        configureFollowButton()
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil){
        //DONT KNOW TRYING TO SELECT PROF IMAGE
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil){ //DONT KNOW IF RIGHT
    }
}
//EXTENSION FOR SELECTE|ING PROF IMAGE
extension HeaderProfileCollectionReusableView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
