//
//  Api.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/4/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
struct Api{
    static var User = UserApi()
    static var Post = PostApi()
    static var Comment = CommentApi()
    static var Post_Comment = Post_CommentApi()
    static var MyPosts = MyPostsApi()
    static var Follow = FollowApi()
    static var Feed = FeedApi()
    static var Notification = NotificationApi()
}
