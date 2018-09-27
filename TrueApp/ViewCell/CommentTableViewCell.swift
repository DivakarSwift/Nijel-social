//
//  CommentTableViewCell.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/3/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userId:String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate: CommentTableViewCellDelegate?

    var comment: Comment?{
        didSet{
            updateView()
            //print(post?.story)
        }
    }
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    func updateView(){
        commentLabel.text = comment?.commentText
    }
    
    func setupUserInfo(){
        accountLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl{
            let photoUrl = URL(string: photoUrlString)
            // profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImage")  )
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accountLabel.text = ""
        commentLabel.text = ""
        
        let tapGestureForAccountLabel = UITapGestureRecognizer(target: self, action: #selector(self.accountLabel_TouchUpInside))
        accountLabel.addGestureRecognizer(tapGestureForAccountLabel) //WAS NAMELABEL
        accountLabel.isUserInteractionEnabled = true //WAS NAMELABEL
    }
    
    @objc func accountLabel_TouchUpInside(){
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //profileImageView.image = UIImage(named: "placeholderImage")
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
