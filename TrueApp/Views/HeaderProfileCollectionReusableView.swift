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
import ProgressHUD

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
    func goToSettingVC()
    func showDateFilter()
    func showUpdateFrameHeight(to height: CGFloat)
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
    @IBOutlet weak var quickFactsView: UIView!
    @IBOutlet weak var showAllButton: UIButton!
    @IBOutlet weak var filterUserPostsLabel: UILabel!
    @IBOutlet weak var segmentToIntroVertConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoButton: UIButton!
    
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
                //textViewBio.isScrollEnabled = true
                textViewBio.isUserInteractionEnabled = false
                editBioButton.setTitle("Edit", for: .normal)
                updateUserBio(with: textViewBio.text)
            }
            if user?.id == Auth.auth().currentUser?.uid {
                infoButton.isHidden = true
            }
        }
    }
    
    var user: User? {
        didSet{
            updateView()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func switchsegment(_ sender: Any) { //is not working for some reason
        if segmentControll.selectedSegmentIndex == 0 {
            postsCountLabel.isHidden = true
            dateFilterButton.isHidden = true
            toLifeStorySection.isHidden = false
        } else {
            postsCountLabel.isHidden = false
            //dateFilterButton.isHidden = false
            //toLifeStorySection.isHidden = true
        }
    }
    
    var oldTextViewBioHeight: CGFloat = 0
    
    @IBAction func showAllAction(_ sender: UIButton) {
        print("showAll")
        if textViewBio.frame.size.height == textViewBio.contentSize.height {
            textViewBio.frame.size.height = oldTextViewBioHeight
            delegate?.showUpdateFrameHeight(to: frame.size.height + (textViewBio.frame.height - textViewBio.contentSize.height))
            showAllButton.setTitle("Show more", for: .normal)
        } else {
            oldTextViewBioHeight = textViewBio.frame.size.height
            textViewBio.frame.size.height = textViewBio.contentSize.height
            delegate?.showUpdateFrameHeight(to: frame.size.height + ( textViewBio.contentSize.height - oldTextViewBioHeight))
          showAllButton.setTitle("Show less", for: .normal)
        }
    }
    
    @IBAction func editProfileAction(_ sender: UIButton) {
        if editProfile {
            bornTextView.isUserInteractionEnabled = false
            relativesTextView.isUserInteractionEnabled = false
            schoolTextView.isUserInteractionEnabled = false
            userDateField.isUserInteractionEnabled = false
            editProfileButton.setTitle("Edit", for: .normal)
            textViewBio.resignFirstResponder()
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["born" : bornTextView.text])
        Database.database().reference().child("users").child(user!.id!).child("quickFacts_edits").childByAutoId().updateChildValues(["user_id": Auth.auth().currentUser!.uid, "time": Date().timeIntervalSince1970])
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["relatives" : relativesTextView.text])
            //Database.database().reference().child("users").child(user!.id!).child("relatives_edits").childByAutoId().updateChildValues(["user_id": Auth.auth().currentUser!.uid, "time": Date().timeIntervalSince1970])
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["school" : schoolTextView.text])
            //Database.database().reference().child("users").child(user!.id!).child("school_edits").childByAutoId().updateChildValues(["user_id": Auth.auth().currentUser!.uid, "time": Date().timeIntervalSince1970])
            editProfile = false
        } else {
            bornTextView.isUserInteractionEnabled = true
            relativesTextView.isUserInteractionEnabled = true
            schoolTextView.isUserInteractionEnabled = true
            userDateField.isUserInteractionEnabled = true
            editProfileButton.setTitle("Save", for: .normal)
            editProfile = true
        }
    }
    
    @IBAction func editBioAction(_ sender: UIButton) {
        editableState = !editableState
//        if textpost.child.user_id != user?.id{
//            cannot be deleted, unless you are account holder
//        }
    }
    
    @IBAction func editDateAction(_ sender: UITextField) {
        Database.database().reference().child("users").child(user!.id!).updateChildValues(["userDate" : userDateField.text as Any])
        Database.database().reference().child("users").child(user!.id!).child("userDate_edits").childByAutoId().updateChildValues(["user_id": Auth.auth().currentUser!.uid, "time": Date().timeIntervalSince1970])
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
        Api.User.isUserBlockedMe(userID: (user?.id!)!) { [weak self] hasBlockedMe in
            if hasBlockedMe {
                self!.editProfileButton.isHidden = true
                self?.editBioButton.isHidden = true
                //self!.editableState = false
                return
            }
        }
        
        
       // if user?.email != nil && (user?.isExclusive)! { //USE
//            editProfileButton.isHidden = true
//            editBioButton.isHidden = true
//            if user?.id == Auth.auth().currentUser?.uid{
//                editProfileButton.isHidden = false
//                editBioButton.isHidden = false
          //  }
//            if (user?.followingSet)!.contains(Auth.auth().currentUser?.uid){
//                editProfileButton.isHidden = false
//                editBioButton.isHidden = false
//            }
            //if user follows you, can edit their profile
        //}
        //self.textViewBio.layer.borderWidth = 1
        //self.textViewBio.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        //self.textViewBio.isScrollEnabled = true
        self.quickFactsView.layer.borderWidth = 0.4
        self.quickFactsView.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        //self.textViewBio.layer.borderWidth = 0.2
        //self.textViewBio.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        textViewBio.text = "Introduction"
        //textViewBio.textColor = UIColor.lightGray
        relativesTextView.text = "Ryan Doe \n Anita Doe \n Ralph Doe"
        bornTextView.text = "ex.                Jane Doe \n January 1st, 1993 \n Durham, North Carolina"
        schoolTextView.text =  "School ('graduation year)" //graduation year
        if user?.bio == "Introduction" {
            textViewBio.textColor = UIColor.lightGray
            textViewBio.font = UIFont(name: "Times New Roman", size: 13.0)
            showAllButton.isHidden = true
        }
        else{
            textViewBio.text = user?.bio
            textViewBio.textColor = UIColor.black
            // let kCMTextMarkupGenericFontName_SansSerif: CFString
            textViewBio.font = UIFont(name: ".SFUIText", size: 11)!
            //textViewBio.isScrollEnabled = true
            let numLines = (textViewBio.contentSize.height / textViewBio.font!.lineHeight)
            if numLines < 9{
                showAllButton.isHidden = true
            }
        }
        
        if user?.bio == nil{
            textViewBio.text = "Introduction"
            textViewBio.textColor = UIColor.lightGray
            textViewBio.font = UIFont(name: "Times New Roman", size: 13.0)
        }
        //        else{
        //            textViewBio.text = user?.bio
        //            textViewBio.textColor = UIColor.black
        //            textViewBio.font = UIFont(name: "Times New Roman", size: 11.0)
        //        }
        
        if user?.born == "ex.                Jane Doe \n January 1st, 1993 \n Durham, North Carolina" {
            bornTextView.textColor = UIColor.lightGray
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        else{
            bornTextView.text = user?.born
            bornTextView.textColor = UIColor.black
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.born == nil{
            bornTextView.text = "ex.                Jane Doe \n January 1st, 1993 \n Durham, North Carolina"
            bornTextView.textColor = UIColor.lightGray
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        //        else{
        //            bornTextView.text = user?.born
        //            bornTextView.textColor = UIColor.black
        //            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        //        }
        
        if user?.relatives == "Ryan Doe \n Anita Doe \n Ralph Doe" {
            relativesTextView.textColor = UIColor.lightGray
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        else{
            relativesTextView.text = user?.relatives
            relativesTextView.textColor = UIColor.black
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.relatives == nil {
            relativesTextView.text = "Ryan Doe \n Anita Doe \n Ralph Doe"
            relativesTextView.textColor = UIColor.lightGray
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        //        else{
        //           // relativesTextView.text = user?.relatives
        //            relativesTextView.textColor = UIColor.black
        //            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        //        }
        
        if user?.school == "School ('graduation year)" {
            schoolTextView.textColor = UIColor.lightGray
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        else{
            schoolTextView.text = user?.school
            schoolTextView.textColor = UIColor.black
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.school == nil {
            schoolTextView.text = "School ('graduation year)"
            schoolTextView.textColor = UIColor.lightGray
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        //        else{
        //            schoolTextView.text = user?.school
        //            schoolTextView.textColor = UIColor.black
        //            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        //        }
        
        //textViewBio.textColor = UIColor.lightGray
        // textViewBio.font = UIFont(name: "Times New Roman", size: 11.0)
        //textViewBio.returnKeyType = .done
        textViewBio.delegate = self
        //bornTextView.returnKeyType = .done
        bornTextView.delegate = self
        //relativesTextView.returnKeyType = .done
        relativesTextView.delegate = self
        //schoolTextView.returnKeyType = .done
        schoolTextView.delegate = self
        //should probably put some of this stuff in updateView, so it only loads once, (or vice versa)
    }
    
    // MARK: UITextViewDelegate
    
    private func time(from timeInterval: Double) -> String {
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
    
    @IBAction func infoButtonTouched(_ sender: Any) {
        print("info button touched")
        let alert = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: {_ in
            ProgressHUD.show()
            print("second test") //never shows
            Api.User.blockUser(userID: (self.user?.id!)!, completion: { error in
                
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else {
                    ProgressHUD.dismiss()
                } //if user already blocked, change to "Unblock User" and take out of blocked users (.remove)
            })
        }))
        alert.addAction(UIAlertAction(title: "Flag user", style: .destructive, handler: {_ in
            ProgressHUD.show()
            Api.User.flagUser(userID: (self.user?.id!)!) { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else {
                    ProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "Completed", message: "User has been flagged", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    ProgressHUD.dismiss()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in alert.dismiss(animated: true)}))
        self.present(alert, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (Auth.auth().currentUser?.uid != user?.id) {
            if range.length == 10 && textViewBio.text.count >= 0 {
                return false
            }
        }
        if text == "\n" { //maybe some should actually return (making a new paragraph)
            //textViewBio.resignFirstResponder()
            //bornTextView.resignFirstResponder()
            //relativesTextView.resignFirstResponder()
            //schoolTextView.resignFirstResponder()
            return true
        }
        
        if text.count > 0 && textView === textViewBio {
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.lightGray]) //stay for 24 hours
            textView.textStorage.insert(attributedString, at: range.location)
            textViewBio.font = UIFont(name: ".SFUIText", size: 11)!
            let cursor = NSRange(location: textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        }
        
        if text.count > 0 && textView === bornTextView {
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.lightGray]) //stay for 24 hours
            textView.textStorage.insert(attributedString, at: range.location)
            bornTextView.font = UIFont(name: "Times New Roman", size: 12)
            let cursor = NSRange(location: textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            bornTextView.textAlignment = .right
            return false
        }
        
        if text.count > 0 && textView === relativesTextView {
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.lightGray]) //stay for 24 hours
            textView.textStorage.insert(attributedString, at: range.location)
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12)
            let cursor = NSRange(location: textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            relativesTextView.textAlignment = .right
            return false
        }
        
        if text.count > 0 && textView === schoolTextView {
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.lightGray]) //stay for 24 hours
            textView.textStorage.insert(attributedString, at: range.location)
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12)
            let cursor = NSRange(location: textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            schoolTextView.textAlignment = .right
            return false
        }
        
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewBio.text == "Introduction"{
            textViewBio.text = ""
            textViewBio.textColor = .black
            textViewBio.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        //        else{
        //            textViewBio.text = user?.bio
        //        }
        if user?.bio == nil {
            textViewBio.text = ""
            textViewBio.textColor = .black
            textViewBio.font = UIFont(name: "Times New Roman", size: 13.0)
        }
        
        if bornTextView.text == "ex.                Jane Doe \n January 1st, 1993 \n Durham, North Carolina"{
            bornTextView.text = ""
            bornTextView.textColor = .black
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.born == nil {
            bornTextView.text = ""
            bornTextView.textColor = .black
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        //        else{
        //            bornTextView.text = user?.born
        //        }
        //
        if relativesTextView.text == "Ryan Doe \n Anita Doe \n Ralph Doe"{
            relativesTextView.text = ""
            relativesTextView.textColor = .black
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.relatives == nil {
            relativesTextView.text = ""
            relativesTextView.textColor = .black
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        
        if schoolTextView.text == "School ('graduation year)"{
            schoolTextView.text = ""
            schoolTextView.textColor = .black
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.school == nil{
            schoolTextView.text = ""
            schoolTextView.textColor = .black
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) { //only works if you click in, then out of hte text view
        if  textViewBio.text == "Introduction"{ //textViewBio.text == "" ||
            textViewBio.text = "Introduction"
            textViewBio.textColor = .lightGray
            textViewBio.font = UIFont(name: "Times New Roman", size: 13.0)
        }
        //        else{
        //            textViewBio.textColor = .black
        //        }
        if user?.bio == nil {
            textViewBio.text = "Introduction"
            textViewBio.textColor = .lightGray
            textViewBio.font = UIFont(name: "Times New Roman", size: 13.0)
        }
        
        if bornTextView.text == "" {
            bornTextView.text = "ex.                Jane Doe \n January 1st, 1993 \n Durham, North Carolina"
            bornTextView.textColor = .lightGray
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.born == nil {
            bornTextView.text = "ex.                Jane Doe \n January 1st, 1993 \n Durham, North Carolina"
            bornTextView.textColor = .lightGray
            bornTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if relativesTextView.text == "" {
            relativesTextView.text = "Ryan Doe \n Anita Doe \n Ralph Doe"
            relativesTextView.textColor = .lightGray
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.relatives == nil {
            relativesTextView.text = "Ryan Doe \n Anita Doe \n Ralph Doe"
            relativesTextView.textColor = .lightGray
            relativesTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if schoolTextView.text == ""{
            schoolTextView.text = "School ('graduation year)"
            schoolTextView.textColor = .lightGray
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
        
        if user?.school == nil{
            schoolTextView.text = "School ('graduation year)"
            schoolTextView.textColor = .lightGray
            schoolTextView.font = UIFont(name: "Times New Roman", size: 12.0)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //        textViewBio.sizeToFit()
        let size = CGSize(width: self.textViewBio.frame.width, height: .infinity)
        _ = textView.sizeThatFits(size)
        //        if estimatedSize.height > 50 {
        //            textViewHeightConstraint.constant = estimatedSize.height
        //        } else {
        //            textViewHeightConstraint.constant = 50
        //        }
        textViewBio.layoutIfNeeded()
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
                if filteredDates.count > 0 { //that one string of text, not the whole text view
                    //let attributedText = NSAttributedString(string: self.textViewBio.text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.red]) //dont make whole text view
                    //self.textViewBio.attributedText = attributedText
                } //unless you edited own profile, no need for different background
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
            if let born_edits = dict["born_edits"] as?  [String: [String: Any]] {
                let filteredDates = born_edits.filter { item in
                    if let timeFrom =  item.value["time"] as? TimeInterval {
                        return (Date().timeIntervalSince1970 - timeFrom) / 60 / 60 < 24
                    }
                    return false
                }
                if filteredDates.count > 0 {
                                      //  let attributedText = NSAttributedString(string: self.textViewBio.text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.red])
                                        //self.textViewBio.attributedText = attributedText
                }
            }
            
            completion(true)
        }
    }
    func getRelatives(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let relatives = dict["relatives"] as? String else { return }
            self.relativesTextView.text = relatives
            if let relatives_edits = dict["relatives_edits"] as?  [String: [String: Any]] {
                let filteredDates = relatives_edits.filter { item in
                    if let timeFrom =  item.value["time"] as? TimeInterval {
                        return (Date().timeIntervalSince1970 - timeFrom) / 60 / 60 < 24
                    }
                    return false
                }
                if filteredDates.count > 0 {
                                     //   let attributedText = NSAttributedString(string: self.textViewBio.text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.red])
                                       // self.textViewBio.attributedText = attributedText
                }
            }
            
            completion(true)
        }
    }
    func getSchool(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let school = dict["school"] as? String else { return }
            self.schoolTextView.text = school
            if let school_edits = dict["school_edits"] as?  [String: [String: Any]] {
                let filteredDates = school_edits.filter { item in
                    if let timeFrom =  item.value["time"] as? TimeInterval {
                        return (Date().timeIntervalSince1970 - timeFrom) / 60 / 60 < 24
                    }
                    return false
                }
                if filteredDates.count > 0 {
                                      //  let attributedText = NSAttributedString(string: self.textViewBio.text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.red])
                                       // self.textViewBio.attributedText = attributedText
                }
            }
            
            completion(true)
        }
    }
    
    
    func getUserDate(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let userDate = dict["userDate"] as? String else { return }
            self.userDateField.text = userDate
            if let userDate_edits = dict["userDate_edits"] as?  [String: [String: Any]] {
                let filteredDates = userDate_edits.filter { item in
                    if let timeFrom =  item.value["time"] as? TimeInterval {
                        return (Date().timeIntervalSince1970 - timeFrom) / 60 / 60 < 24
                    }
                    return false
                }
                if filteredDates.count > 0 {
                                       // let attributedText = NSAttributedString(string: self.textViewBio.text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.red])
                                        //self.textViewBio.attributedText = attributedText
                }
            }
            
            completion(true)
        }
    }
    
    func updateView() {
        self.nameLabel.text = user!.fullName
        self.textViewBio.delegate = self
        self.bornTextView.delegate = self
        self.relativesTextView.delegate = self
        self.schoolTextView.delegate = self
        self.bornTextView.sizeToFit()
        self.bornTextView.layoutIfNeeded()
        let contentSize = self.bornTextView.sizeThatFits(self.bornTextView.bounds.size)
        //self.relativesTextView.sizeToFit()
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
            // userDateField.isUserInteractionEnabled = true
            followButton.setTitle("Edit Profile", for: UIControl.State.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControl.Event.touchUpInside)
        } else {
            //userDateField.isUserInteractionEnabled = false
            updateStateFollowButton()
        }
        
        if user?.myPosts == nil{
            postsCountLabel.isHidden = true
        }
        else{
            postsCountLabel.isHidden = false
        }
        
        if user?.email == nil{ //if profile (no user), hide filterswitch
            filterSwitch.isHidden = true
            filterUserPostsLabel.isHidden = true
        }
        else{
            filterSwitch.isHidden = false
            filterUserPostsLabel.isHidden = false
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
        if user?.id == Auth.auth().currentUser!.uid {
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
    
    func configureFollowButton() {
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
