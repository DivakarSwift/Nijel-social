//
//  TrueFeedViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/2/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import FirebaseAuth

class TrueFeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
   // let refreshControl = UIRefreshControl()
    
    var posts = [Post]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        //tableView.delegate = self
        loadPosts()
    }
    
    func fetchUser(uid:String, completed: @escaping () -> Void){
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.insert(user, at: 0)
            completed()
        })
    }
    
    func loadPosts(){
        
        Api.Feed.observeFeed(withId: Auth.auth().currentUser!.uid) { (post) in //switched Api.User.CURRENT_USER! to Auth.auth().currentUser!
            guard let postUid = post.uid else{
                return
            }
            self.fetchUser(uid: postUid, completed:{
                self.posts.insert(post, at: 0)
                self.tableView.reloadData()
        })
        }
        Api.Feed.getRecentFeed(withId: Auth.auth().currentUser!.uid, start: posts.first?.timestamp, limit: 5) { (results) in
            if results.count > 0{
                results.forEach({ (result) in
                    self.posts.append(result.0)
                    self.users.append(result.1)
                })
            }
            self.tableView.reloadData()
        }
        
        Api.Feed.observeFeedRemoved(withId: Auth.auth().currentUser!.uid) { (post) in
            self.posts = self.posts.filter{ $0.id != post.id }
            self.users = self.users.filter{ $0.id != post.uid }
            self.tableView.reloadData()
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "Feed_ProfileSegue"{
            let userPostsVC = segue.destination as! ProfileUserPostsViewController
            let userId = sender as! String
            userPostsVC.userId = userId
    }
}
}

extension TrueFeedViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! FeedTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension TrueFeedViewController: FeedTableViewCellDelegate{
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Feed_ProfileSegue", sender: userId)
    }
}
