//
//  CreatePostTableViewCell.swift
//  TrueApp
//
//  Created by Stanislau Sakharchuk on 9/28/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

class CreatePostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    var completion: (() -> ())?
    @IBOutlet weak var addPhotoFromGaleryButton: UIButton!
    @IBAction func addPhotoFromGalery(_ sender: UIButton) {
        if let comp = completion {
            comp()
            return
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.isScrollEnabled = false
        textViewDidChange(textView)
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
        //        hideKeyboard()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.endEditing(true) //would make it so i could touch out of text field and keyboard will disappear
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        //let  char = text.cString(using: String.Encoding.utf8)!
        //let isBackSpace = strcmp(char, "\\b")
        
        if textView.text == "Story Behind Post: " && range.length > 0 { //Backspace
            
        }
        return true
   //     if (isBackSpace == -92) {
            // If backspace is pressed this will call
      //      if textView.text == "Story Behind Post: " {
      //          return false
      //      }
      //  }
     //   return true
    }
    
   
}

extension CreatePostTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let numLines = (textView.contentSize.height / textView.font!.lineHeight)
        let size = CGSize(width: self.frame.width, height: .infinity)
                let estimatedSize = textView.sizeThatFits(size)
                if estimatedSize.height > 20 {
                    textViewHeightConstraint.constant = 225
//                    if range.location == 0 {
//                        return false
//                    }
//
//                    if (0 < range.location && range.location < count(string.utf16)) == true {
//                        return false
                    //}
                } else if numLines < 12{
                    textViewHeightConstraint.constant = estimatedSize.height
                }
        layoutIfNeeded()
    }
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
}
