//
//  PostViewController.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 9/30/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgSizeValue  {
            var contentInsets: UIEdgeInsets
            if UIDevice.current.orientation == .portrait {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.height), right: 0.0);
            } else {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.width), right: 0.0);
            }
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            viewBottomConstraint.constant = contentInsets.bottom
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        viewBottomConstraint.constant = 0
    }
    
}


//extension PostViewController: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        let size = CGSize(width: self.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        if estimatedSize.height > 20 {
//            textViewHeightConstraint.constant = estimatedSize.height
//        } else {
//            textViewHeightConstraint.constant = 20
//        }
//        layoutIfNeeded()
//    }
//}
