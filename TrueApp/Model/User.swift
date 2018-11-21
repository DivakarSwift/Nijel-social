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
    var followingSet: Bool?//[String:[String: Any]]?//NSMutableSet?
    var followerSet: Bool?//[String:[String: Any]]?//NSMutableSet?
    var phoneNumber:String? //shortBio, Birthday
    var IPosted: [String:[String: Any]]?
    var myPosts: [String:[String: Any]]?
    var bio: String?
    var born: String?
    var lifeStory: String?
    var relatives: String?
    var school: String?
    var userDate: String?
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
        user.IPosted = dict["IPosted"] as? [String:[String: Any]]
        user.myPosts = dict["myPosts"] as? [String:[String: Any]]
        user.bio = dict["bio"] as? String
        user.born =  dict["born"] as? String
        user.lifeStory = dict["lifeStory"] as? String
        user.relatives = dict["relatives"] as? String
        user.school = dict["school"] as? String
        user.userDate = dict["userDate"] as? String
        user.followingSet = dict["followingSet"] as? Bool // [String:[String: Any]]//listToHashSet(list: dict["Following"] as? [String: Any])
        user.followerSet = dict["followerSet"] as? Bool //[String:[String: Any]]//listToHashSet(list: dict["Followers"] as? [String: Any])
        return user
    }
    
    static func listToHashSet(list: [String: Any]?) -> NSMutableSet{
        let set = NSMutableSet()
        if list == nil{
            return set
        }
        for string in list!{
            set.add(string)
        
        }
        return set
    }
}
