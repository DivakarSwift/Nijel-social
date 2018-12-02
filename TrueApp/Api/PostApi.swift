//
//  PostApi.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/4/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class PostApi{
    
    let userAPI = UserApi()
    
    var REF_POSTS = Database.database().reference().child("posts")
    func observePosts(completion: @escaping (Post) -> Void){
        REF_POSTS.observe(.childAdded){
            (snapshot:DataSnapshot) in
            if let dict = snapshot.value as? [String: Any]{
                let newPost = Post.transformPostPhoto(dict: dict, key: snapshot.key)                
                completion(newPost)
            }
        }
    }
    

    
    func observePost(withId id : String, completion: @escaping (Post) -> Void){
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                    let post = Post.transformPostPhoto(dict: dict, key: snapshot.key)
                    completion(post)
                }
        })
}
    func observeLikeCount(withPostId id: String, completion: @escaping (Int) -> Void){
        REF_POSTS.child(id).observe(.childChanged, with: {
            snapshot in
            if let value = snapshot.value as? Int{
                completion(value)
            }
        })
    }
    
    func observeTopPosts(completion: @escaping (Post) -> Void){
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: {
            snapshot in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = snapshot.value as? [String: Any]{
                    let newPost = Post.transformPostPhoto(dict: dict, key: child.key)
                    completion(newPost)
                }
            })
        })
    }
    
    func removeObservelikeCount(id: String, likeHandler: UInt){
        Api.Post.REF_POSTS.child(id).removeObserver(withHandle: likeHandler)
    }
    
    
    func incrementLikes(postId: String, onSuccess: @escaping (Post) -> Void, onError: @escaping(_ errorMessage:String?)-> Void){
        let postRef = Api.Post.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid { //ERROR
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any]{
                let post = Post.transformPostPhoto(dict: dict, key: snapshot!.key)
                onSuccess(post)
            }
        }
    }
    
    func flagPost(by id: String, completion: @escaping(Error?)->Void) {
        Database.database().reference().child("flagged_posts").childByAutoId().updateChildValues(["post_id": id]) { error, _ in
                completion(error)
            }
    }
    
    func deletePost(post: Post) {
        Database.database().reference().child("users").child(post.postToUserId ?? "").child("IPosted").child(post.id ?? "").removeValue()
        Database.database().reference().child("users").child(post.postToUserId ?? "").child("myPosts").child(post.id ?? "").removeValue()
        Database.database().reference().child("users").child(post.postToUserId ?? "").child("SavedPosts").child(post.id ?? "").removeValue()
        Database.database().reference().child("users").child(post.postFromUserId ?? "").child("IPosted").child(post.id ?? "").removeValue()
        Database.database().reference().child("users").child(post.postFromUserId ?? "").child("myPosts").child(post.id ?? "").removeValue()
        Database.database().reference().child("users").child(post.postFromUserId ?? "").child("SavedPosts").child(post.id ?? "").removeValue()
    }
}
