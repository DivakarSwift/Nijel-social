//
//  UserApi.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/4/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class UserApi{
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUserByUsername(username:String, completion: @escaping (User) -> Void){
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }) //have to add this to database from search
    }
    
    func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    func observeCurrentUser(completion: @escaping (User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        print(currentUser.uid)
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
                
            }
        })

    }
    func observeUsers(completion: @escaping (User) -> Void) {
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String:Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                    completion(user)
                }
        })
    }
    func queryUsers(withText text : String, completion: @escaping ([User]) -> Void) {
        REF_USERS.queryOrdered(byChild: "fullName").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { snapshot in
            var users = [User]()
            for child in snapshot.children {
                print(child)
                if let dataSnapShot = child as? DataSnapshot, let dict = dataSnapShot.value as? [String : Any] {
                    let user = User.transformUser(dict: dict, key: dataSnapShot.key)
                    users.append(user)
                }
            }
            self.REF_USERS.queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text + "\u{F8FF}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    if let dataSnapShot = child as? DataSnapshot, let dict = dataSnapShot.value as? [String : Any] {
                        let user = User.transformUser(dict: dict, key: dataSnapShot.key)
                        users.append(user)
                    }
                }
                completion(users)
            })
        })
    }
    
//    var CURRENT_USER: User?{
//        if let currentUser = Auth.auth().currentUser{
//            return currentUser //NEED THIS
//        }
//        return nil
//    }
    
    var REF_CURRENT_USER: DatabaseReference?{
        guard let currentUser = Auth.auth().currentUser else{
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
}
