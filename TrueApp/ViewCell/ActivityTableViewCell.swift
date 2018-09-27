//
//  ActivityTableViewCell.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/12/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    var notification: Notification?{
        didSet{
            updateView()
        }
    }
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    
    func updateView(){
        
    }
    
    func setupUserInfo(){
        nameLabel.text = user?.fullName //might want username
        if let photoUrlString = user?.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "squareprofile")  ) //shouldnt need this because profile image shouldnt be on post
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
