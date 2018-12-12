//
//  DetailViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/9/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var postId = ""
    var post = Post()
    var user = User()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableView.automaticDimension
        loadPost()
    }
    
    func loadPost(){
//        Api.Post.observePost(withId: postId) { (post) in
//            guard let postUid = post.uid else{
//                return
//            }
//            self.fetchUser(uid: postUid, completed:{
//                self.post = post
//                self.tableView.reloadData()
//            })
//        }
    }
    
    func fetchUser(uid:String, completed: @escaping () -> Void){
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.user = user
            completed()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentVC"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "Detail_UserProfileSegue"{
            let userPostsVC = segue.destination as! ProfileUserPostsViewController
            let userId = sender as! String
            userPostsVC.userId = userId
        }
    }
}

extension DetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! FeedTableViewCell
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension DetailViewController: FeedTableViewCellDelegate{
    func goToCommentVC(postId: String) {
        print("commentImageView_TouchUpInside was called")
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Detail_UserProfileSegue", sender: userId)
    }
}

extension DetailViewController: HomePageBigPostCollectionViewCellDelegate{
    func comment_Segue(postId: String) {
        print("commentImageView_TouchUpInside was called")
        performSegue(withIdentifier: "Detail_CommentVC", sender: postId)
    }
    func profile_Segue(userId: String) {
        performSegue(withIdentifier: "Detail_UserProfileSegue", sender: userId)
    }
}
