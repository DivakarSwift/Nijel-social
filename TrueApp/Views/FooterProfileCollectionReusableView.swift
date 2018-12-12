//
//  FooterProfileCollectionReusableView.swift
//  TrueApp
//
//  Created by Evgeny on 11/7/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class FooterProfileCollectionReusableView: UICollectionReusableView {

    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var lifeStoryTextView: UITextView!
    
    var editStory = false
    
    var user: User?{
        didSet{
            updateView()
        }
    }
 
    @IBAction func editLifeStoryAction(_ sender: UIButton) {
        if editStory {
            UserDefaults.standard.set(true, forKey: "isEditStory")
            lifeStoryTextView.isUserInteractionEnabled = false
            editButton.setTitle("Edit", for: .normal)
            lifeStoryTextView.resignFirstResponder()
            Database.database().reference().child("users").child(user!.id!).updateChildValues(["lifeStory" : lifeStoryTextView.text])
            editStory = false
            //lifeStoryTextView.becomeFirstResponder()
        } else {
            UserDefaults.standard.set(false, forKey: "isEditStory")
            lifeStoryTextView.isUserInteractionEnabled = true
            editButton.setTitle("Save", for: .normal)
            editStory = true
          //  lifeStoryTextView.resignFirstResponder()
        }

    }
 
    
    func getLifeStory(completion: @escaping(Bool) ->()) {
        Database.database().reference().child("users").child(user!.id!).observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot as DataSnapshot
            let dict = snap.value as! [String: Any]
            guard let lifeStory = dict["lifeStory"] as? String else { return }
            self.lifeStoryTextView.text = lifeStory
            completion(true)
        }
    }
    
//    @objc func keyboardWillShow(sender: NSNotification) {
//        self.view.frame.origin.y -= 250
//    }
//    @objc func keyboardWillHide(sender: NSNotification) {
//        self.view.frame.origin.y += 250
//    }
    func updateView() {
        lifeStoryTextView.isUserInteractionEnabled = false
        let fixedWidth = lifeStoryTextView.frame.size.width
        let newSize = lifeStoryTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        lifeStoryTextView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        _ = CGSize(width: self.frame.width, height: .infinity)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        getLifeStory { (completion) in
        }
        
        
    }

}
