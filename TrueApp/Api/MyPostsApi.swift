//
//  MyPostsApi.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/5/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MyPostsApi{
    var REF_MYPOSTS = Database.database().reference().child("Posts")
    
    func fetchMyPosts(userId: String, completion: @escaping (String) -> Void){
        REF_MYPOSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    func fetchCountMyPosts(userId:String, completion: @escaping (Int) -> Void){
        REF_MYPOSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
