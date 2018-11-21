//
//  CommentHeadCell.swift
//  TrueApp
//
//  Created by Stanislau Sakharchuk on 9/30/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

class CommentHeadCell: UITableViewCell {
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    
    weak var cellDelegate: YourCellDelegate?
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton()
    }
    
}
