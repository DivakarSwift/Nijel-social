//
//  ExpandableTextCell.swift
//  TrueApp
//
//  Created by Sorochinskiy Dmitriy on 22.11.2018.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class ExpandableTextCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var dropDownImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textEdit: UITextView!
    
    var isExpanded = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.dropDownImage.transform  = self.isExpanded ? CGAffineTransform(rotationAngle: CGFloat(Double.pi))  : CGAffineTransform.identity 
            }
        }
    }
    
}
