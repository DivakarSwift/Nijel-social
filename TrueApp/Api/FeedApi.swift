//
//  FeedApi.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/7/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FeedApi{
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeFeed(withId id: String, completion: @escaping (Post) -> Void){
            REF_FEED.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    func getRecentFeed(withId id: String, start timestamp: Int? = nil, limit: UInt, completion: @escaping ([(Post, User)]) -> Void){
        let feedQuery = REF_FEED.child(id).queryOrdered(byChild: "timestamp").queryLimited(toLast: limit)
        var  results: [(post: Post, user: User)] = []
        feedQuery.observeSingleEvent(of: DataEventType.value) {
            snapshot in
            let items = snapshot.children.allObjects as! [DataSnapshot]
            let myGroup = DispatchGroup()
            for(index, item) in items.enumerated(){
                myGroup.enter()
                Api.Post.observePost(withId: item.key, completion: { (post) in
                    Api.User.observeUser(withId: post.id!, completion: { (user) in
                        results.insert((post, user), at: index)
                        myGroup.leave()
                    })
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: {
                //results.sort(by: {$0.0.timestamp! > $1.0.timestamp!})
                completion(results)
            })
        }
    }
    func observeFeedRemoved(withId id: String, completion: @escaping (Post) -> Void){
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            Api.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
