//
//  CreateByographyPostCollectionViewCell.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 10/7/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

class CreateByographyPostCollectionViewCell: UICollectionViewCell {
    var closure: (()->())?
    @IBAction func createByographyPost(_ sender: UIButton) {
        guard let cl = closure else { return }
        cl()
    }
    
}
