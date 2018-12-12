//
//  SavedTableViewCell.swift
//  TrueApp
//
//  Created by Stanislau on 10/21/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseStorage

class SavedTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var postTableView: UIView!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var avatarLabel: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
        var post: Post?{
            didSet{
                updateView()
            }
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
                    guard let data = data else { return }
                    self?.descLabel.text = self!.post?.postFromUserId 
                    self?.avatarLabel.image = UIImage(data: data)
                    self?.post?.image = UIImage(data: data)
                    self?.postTableView.layer.borderWidth = 1
                    self?.postTableView.layer.borderColor = UIColor(red:0/255, green:0/255, blue:0/255, alpha: 1).cgColor
                }
            }
        }
    
    
}
