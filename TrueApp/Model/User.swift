//
//  User.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/3/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
class User{
    var email:String?
    var profileImageUrl:String?
    var fullName:String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
    var phoneNumber:String? //shortBio, Birthday
}


extension User{
     static func transformUser(dict: [String: Any], key: String) -> User {
        let user = User()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.id = key
        user.fullName = dict["fullName"] as? String
        user.phoneNumber = dict["phoneNumber"] as? String
        return user
    }
}
