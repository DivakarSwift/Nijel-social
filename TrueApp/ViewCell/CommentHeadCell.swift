//
//  CommentHeadCell.swift
//  TrueApp
//
//  Created by Stanislau Sakharchuk on 9/30/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

protocol CommentHeadeCellDelegate: class {
    func commentButtonTouched(with postID: String)
}

class CommentHeadCell: UITableViewCell {
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postedToAccountLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    weak var delegate: CommentHeadeCellDelegate?
    var postID: String!
    var userID: String!
    
    func viewDidLayoutSubviews() {
        super.layoutSubviews()
        //topLabel.text = user?.fullName
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentButton_TouchUp_Inside))
        commentButton.addGestureRecognizer(tapGesture)
        commentButton.isUserInteractionEnabled = true
        //commentLabel.addGestureRecognizer(tapGesture)
        //commentLabel.isUserInteractionEnabled = true
        //postedToAccountLabel.text = "Story of:" + post?.postToUserId
    } //doesnt work, should have label start at top left
    
    weak var cellDelegate: YourCellDelegate?
    
    
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton()
        likeButton.setBackgroundImage(UIImage(named: "save"), for: .normal)
    }
    @IBAction func commentButton_TouchUp_Inside(_ sender: Any) {
        print("commentButton pressed")
        delegate?.commentButtonTouched(with: postID)
//        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
//        let commentVC = storyboard.instantiateViewController(withIdentifier: "CommentViewController")
//        navigationController?.pushViewController(commentVC, animated: true)
        //send to comment view
    }
    
    @IBAction func didPressTopLabelButton(_ sender: Any) {
        cellDelegate?.didPresetTopLabel(with: userID)
    }
    
    //    func updateView(){
    //        self.subscriptionLabel.sizeToFit()
    //    }
}
