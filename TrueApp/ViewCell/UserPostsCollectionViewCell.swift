//
//  UserPostsCollectionViewCell.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/6/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

protocol UserPostsCollectionViewCellDelegate {
    func goToDetailVC(postId: String)
}

class UserPostsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: UserPostsCollectionViewCellDelegate?
    
    var post: Post?{
        didSet{
            updateView()
        }
    }
    func updateView(){
        if let photoUrlString = post?.photoUrl{
            let photoUrl = URL(string: photoUrlString)
            photo.sd_setImage(with: photoUrl)
        }
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(tapGestureForPhoto) //WAS NAMELABEL
        photo.isUserInteractionEnabled = true //WAS NAMELABEL

    }
    
    @objc func photo_TouchUpInside(){
        if let id = post?.id {
            delegate?.goToDetailVC(postId: id)
        }
    }
}
