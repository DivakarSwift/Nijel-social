//
//  ExpandableTextCell.swift
//  TrueApp
//
//  Created by Sorochinskiy Dmitriy on 22.11.2018.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

protocol ExpandableTextCellDelegate: class {
    func textDidEndEditing(_ text: String, type: ExpandableTextCell.ExpandableCellType)
}

class ExpandableTextCell: UICollectionViewCell {

    enum ExpandableCellType: String {
        case earlyLife, education, career, personalLife
    }
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var dropDownImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textEdit: UITextView!
    
    var cellType: ExpandableCellType!
    
    var isExpanded = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.dropDownImage.transform  = self.isExpanded ? CGAffineTransform(rotationAngle: CGFloat(Double.pi))  : CGAffineTransform.identity
                self.editButton.isHidden = self.isExpanded
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
        return true
    }
}
