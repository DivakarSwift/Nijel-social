//
//  ExpandableTextCell.swift
//  TrueApp
//
//  Created by Sorochinskiy Dmitriy on 22.11.2018.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


protocol ExpandableTextCellDelegate: class {
    func textDidEndEditing(_ text: String, type: ExpandableTextCell.ExpandableCellType)
}

class ExpandableTextCell: UICollectionViewCell {

    enum ExpandableCellType: String {
        case earlyLife, education, career, personalLife, hobbies
    }
    
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var dropDownImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textEdit: UITextView!
    
    var cellType: ExpandableCellType!
    
    var user: User!
    var edit = false
    
    var isExpanded = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.dropDownImage.transform  = self.isExpanded ? CGAffineTransform(rotationAngle: CGFloat(Double.pi))  : CGAffineTransform.identity
                self.editButton.isHidden = self.isExpanded
               // if user?.isExclusive and ur not in follower list hide edit button
                //if user has blocked you, hide edit button
                if self.isExpanded == false{
                    print("shouldChangeHeight")
                    var frame = self.textEdit.frame
                    frame.size.height = self.textEdit.contentSize.height
                    self.textEdit.frame = frame
                    //this should wor
                }
                if self.textEdit.text! == "" {
                    print("what is happening")
                    self.textEdit.text = "Write something"
                    self.textEdit.textColor = UIColor.lightGray
                }
               // if self.user?.earlyLife == nil || (self.user?.earlyLife)! == ""{
                //    self.textEdit.text = "Write something"
                    //self.textEdit.textColor = UIColor.lightGray
               // }//this should work?????
//                Api.User.isUserBlockedMe(userID: (self.user?.id!)!) { [weak self] hasBlockedMe in
//                    if hasBlockedMe {
//                        self!.editButton.isHidden = true
//                        return
//                    }
//                } //error somehow
            }
        }
    }
    
    var isEditingMode = false {
        didSet {
            textEdit.isEditable = isEditingMode
            editButton.setTitle(isEditingMode ? "Save": "Edit", for: .normal)
            if !isEditingMode {
                delegate?.textDidEndEditing(textEdit.text, type: cellType)
            }
        }
    }
    
    weak var delegate: ExpandableTextCellDelegate?
    
//    func textFieldDidBeginEditing(_ textField: UITextField) { // became first responder
//
//        //move textfields up
//        let myScreenRect: CGRect = UIScreen.main.bounds
//        let keyboardHeight : CGFloat = 216
//
//        UIView.beginAnimations( "animateView", context: nil)
//        var _:TimeInterval = 0.35
//        var needToMove: CGFloat = 0
//
//        var frame : CGRect = self.textEdit.frame
//        if (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.shared.statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
//            needToMove = (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.shared.statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
//        }
//
//        frame.origin.y = -needToMove
//        self.textEdit.frame = frame
//        UIView.commitAnimations()
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        //move textfields back down
//        UIView.beginAnimations( "animateView", context: nil)
//        var _:TimeInterval = 0.35
//        var frame : CGRect = self.textEdit.frame
//        frame.origin.y = 0
//        self.textEdit.frame = frame
//        UIView.commitAnimations()
//    }
    
    
//    func viewDidLoad(){
//        //super.viewDidLoad()
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.keyboardWillShow(notification:)),
//            name: UIResponder.keyboardDidShowNotification, object: nil)
//    }
//    
//    @objc func keyboardWillShow(notification:NSNotification) {
//        
//        if let info = notification.userInfo {
//            
//            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
//            
//            
//            self.textEdit.layoutIfNeeded()
//            
//            UIView.animate(withDuration: 0.25, animations: {
//                
//                self.textEdit.layoutIfNeeded()
//                self.bottomTextViewConstraint.constant = rect.height + 20
//                
//            })
//            
//        }
//    }
    
    
    @IBAction func editButtonTouched(_ sender: Any) {
        isEditingMode = !isEditingMode
    //Database.database().reference().child("users").child(user!.id!).child("expandableText_edits").childByAutoId().updateChildValues(["user_id": Auth.auth().currentUser!.uid, "time": Date().timeIntervalSince1970])
       // make textView height as big as content
        //keep track who edits (userid)
    }
    
//    func viewDidLoad() {
//        self.textEdit.text = "Write something"
//    }
}

//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) { //only works if you click in, then out of hte text view
//
//    }
extension ExpandableTextCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count > 0 && textView === textEdit{ //&& post.date! + 86400.0 > hours
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.backgroundColor: UIColor.lightGray])
            textView.textStorage.insert(attributedString, at: range.location)
            textEdit.font = UIFont(name: ".SFUIText", size: 13)!
            let cursor = NSRange(location: textView.selectedRange.location+1, length: 0)
            textView.selectedRange = cursor
            return false
        }
        
//        if self.textEdit.text! == "" {
//            self.textEdit.text = "Write something"
//        }
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        //if user is exclsuive, hide edit button
        return true
    }
    
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
    //    @objc func keyboardWillShow(sender: NSNotification) {
    //        self.view.frame.origin.y -= 250
    //    }
    //    @objc func keyboardWillHide(sender: NSNotification) {
    //        self.view.frame.origin.y += 250
    //    }
}

