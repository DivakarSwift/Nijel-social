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
import EasyTipView
import ProgressHUD

protocol ExpandableTextCellDelegate: class {
    func textDidEndEditing(_ text: String, type: ExpandableTextCell.ExpandableCellType)
}

class ExpandableTextCell: UICollectionViewCell {

    enum ExpandableCellType: String, CaseIterable {
        case earlyLife, education, career, personalLife, hobbies
    }
    
    @IBOutlet weak var bottomTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var dropDownImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textEdit: UITextView!
    let userApi = UserApi()
    var tipView: EasyTipView?
    var cellType: ExpandableCellType!
    
    var edit = false
    
    var isExpanded = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.dropDownImage.transform  = self.isExpanded ? CGAffineTransform(rotationAngle: CGFloat(Double.pi))  : CGAffineTransform.identity
                self.editButton.isHidden = self.isExpanded
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
            }
        }
    }
    
    var isEditingMode = false {
        didSet {
            textEdit.isEditable = isEditingMode
            editButton.setTitle(isEditingMode ? "Save": "Edit", for: .normal)
            if !isEditingMode {            delegate?.textDidEndEditing(textEdit.attributedText.archineWithUsersIds(), type: cellType)
            }
        }
    }
    
    func setupWithModel() {
        textEdit.dataDetectorTypes = .link
        textEdit.typingAttributes = [.link: String().getUserAttributes()]
    }
    
    weak var delegate: ExpandableTextCellDelegate?
  
    
    @IBAction func editButtonTouched(_ sender: Any) {
        isEditingMode = !isEditingMode
    }
}

extension ExpandableTextCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if textView.attributedText.length > 0, text != " ", let userID = textEdit.attributedText.attribute(.link, at: range.location - ( range.location == 0 ? 0 : 1), effectiveRange: nil) as? URL {
            if Auth.auth().currentUser?.uid != userID.absoluteString {
                return false
            }
        }
        textEdit.typingAttributes = String().getUserAttributes()

        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        ProgressHUD.show()
        userApi.observeUser(withId: URL.absoluteString) { user in
            ProgressHUD.dismiss()
            self.tipView?.dismiss()
            self.tipView = EasyTipView(text: String(user.fullName ?? ""))
            self.tipView?.show(forView: textView)
        }
        
        return false
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

