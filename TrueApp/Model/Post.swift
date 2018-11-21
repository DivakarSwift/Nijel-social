//
//  Post.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/2/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

class Post {
    var id: String?
    var imgURL: String?
    var date: Double?
    var postFromUserId: String?
    var postToUserId: String?
    var text: String?
    var whoPosted: String?
    var image: UIImage?
    var isWatchedByUser: Bool?
    var contentDate: Double?
}
extension Post{
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.imgURL = dict["imgURL"] as? String
        post.date = dict["date"] as? Double
        post.postFromUserId = dict["postFromUserId"] as? String
        post.postToUserId = dict["postToUserId"] as? String
        post.text = dict["text"] as? String
        post.whoPosted = dict["whoPosted"] as? String
        post.isWatchedByUser = dict["isWatchedByUser"] as? Bool
        post.contentDate = dict["contentDate"] as? Double
        return post
    }
    static func transformPostVideo(){
        
    }
    
    static func transformPostWriting(){
        
    }
}
