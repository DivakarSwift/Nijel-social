//
//  Post.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/2/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseAuth

class Post{
    var story: String?
    var photoUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio : CGFloat?
    var videoUrl: String?
    var timestamp: Int?
}
extension Post{
    static func transformPostPhoto(dict: [String: Any], key: String) -> Post{
        let post = Post()
        post.id = key
        post.story = dict["story"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        if let currentUserId = Auth.auth().currentUser?.uid{
            if post.likes != nil{
                post.isLiked = post.likes![currentUserId] != nil
        }
        }
        return post
    }
    static func transformPostVideo(){
        
    }
    
    static func transformPostWriting(){
        
    }
}
