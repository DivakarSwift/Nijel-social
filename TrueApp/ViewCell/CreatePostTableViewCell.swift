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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension CreatePostTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height > 20 {
            textViewHeightConstraint.constant = estimatedSize.height
        } else {
            textViewHeightConstraint.constant = 20
        }
        layoutIfNeeded()
    }
}

