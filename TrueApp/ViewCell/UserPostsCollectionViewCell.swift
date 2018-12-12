//
//  UserPostsCollectionViewCell.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/6/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseStorage

protocol UserPostsCollectionViewCellDelegate {
    func goToDetailVC(postId: String)
}

class UserPostsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var text: UILabel!
    
    var delegate: UserPostsCollectionViewCellDelegate?
    
    var post: Post?{
        didSet{
            updateView()
        }
    }
    
    override func prepareForReuse() {
        photo.image = nil
        super.prepareForReuse()
    }
    
    func updateView(){
        let storage = Storage.storage()
        if let url = post?.imgURL {
            let spaceRef = storage.reference(forURL: "gs://first-76cc5.appspot.com/\(url)")
            spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                self?.photo.contentMode = .scaleAspectFill
                guard let data = data else { return }
                self?.photo.image = UIImage(data: data)
                self?.post?.image = UIImage(data: data)
            }
            
            //        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
            //        photo.addGestureRecognizer(tapGestureForPhoto) //WAS NAMELABEL
            //        photo.isUserInteractionEnabled = true //WAS NAMELABEL
        } else {
            self.photo.contentMode = .center
            self.photo.image = UIImage(named: "no-waiting")
        }
        text.text = post?.text
    }
    
    @objc func photo_TouchUpInside(){
        if let id = post?.id {
            delegate?.goToDetailVC(postId: id)
        }
    }
}
