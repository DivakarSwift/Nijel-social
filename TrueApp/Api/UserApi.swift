//
//  UserApi.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/4/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD
import MessageUI

class UserApi{
    var REF_USERS = Database.database().reference().child("users")
    var REF_BLOCKED_USERS = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("blocked_users")
    
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
                    if user.isDeactivated != true {
                        users.append(user)
                    }
                }
            }
            self.REF_USERS.queryOrdered(byChild: "username").queryStarting(atValue: text).queryEnding(atValue: text + "\u{F8FF}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    if let dataSnapShot = child as? DataSnapshot, let dict = dataSnapShot.value as? [String : Any] {
                        let user = User.transformUser(dict: dict, key: dataSnapShot.key)
                        if user.isDeactivated != true {
                            users.append(user)
                        }
                    }
                }
                completion(users)
            })
        })
    }
    
    func checkForUserDeactivated(userID: String, completion: @escaping(Bool)->Void) {
        REF_USERS.child(userID).observe(.value) { snapshot in
            if let dict = snapshot.value as? [String:Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user.isDeactivated == true)
            }
        }
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
    
    func flagUser(userID: String, completion: @escaping(Error?)->Void) {
        Database.database().reference().child("flagged_users").childByAutoId().updateChildValues(["userID": userID]) { error, _ in
            completion(error)
        } //add alert here?
    }
    
    func blockUser(userID: String, completion: @escaping(Error?)->Void) {
        if (Auth.auth().currentUser?.uid) != nil {
            let db = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("blocked_users")
            db.child(userID).observeSingleEvent(of: .value, with: {
                snapshot in
                print("snapshot.exists()")
                if snapshot.exists(){
                    db.child(userID).removeValue()
                    let alertController = UIAlertController(title: "Completed", message: "User has been unblocked", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                   // self.present(alertController, animated: true, completion: nil)
                    ProgressHUD.dismiss()
                    
                } else{
                    self.REF_BLOCKED_USERS.child(userID).setValue(true)
                    let alertController = UIAlertController(title: "Completed", message: "User has been blocked", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                   // self.present(alertController, animated: true, completion: nil)
                    ProgressHUD.dismiss()
                    
       //completion(nil)
                    //ProgressHUD.dismiss()
    }
            }
        )}
    }
    
    func isBlockedUser(userID: String, completion: @escaping(Bool) -> Void) {
        self.REF_BLOCKED_USERS.child(userID).observeSingleEvent(of: .value, with: {
            snapshot in
            let val = snapshot.value as? NSNull
            if (val != nil) {
                completion(false)
            } else{
                completion(true)
            }
        })
    }
    
    func isUserBlockedMe(userID: String, completion: @escaping(Bool) -> Void) {
        self.REF_USERS.child(userID).child("blocked_users").child((Auth.auth().currentUser?.uid)!).observe(.value) {  snapshot in
            let val = snapshot.value as? NSNull
            if (val != nil) {
                completion(false)
            } else{
                completion(true)
            }
        }
    }
}
