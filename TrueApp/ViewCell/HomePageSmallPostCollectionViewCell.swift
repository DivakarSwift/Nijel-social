//
//  HomePageSmallPostTableViewCell.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 10/2/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class HomePageSmallPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBAction func heartButtonPressed(_ sender: UIButton) {
    }
    
    var post: Post?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        let storage = Storage.storage()
        let spaceRef = storage.reference(forURL: "gs://first-76cc5.appspot.com/\(post!.imgURL!)")
        spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            self?.leftImageView.image = UIImage(data: data)
            self?.post?.image = UIImage(data: data)
        }
    }
}
