//
//  Comment.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/4/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
class Comment{
    var commentText: String?
    var uid: String?
    
}
extension Comment{
    static func transformComment(dict: [String: Any]) -> Comment{
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
