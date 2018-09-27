//
//  ProfileUserPostsViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/8/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class ProfileUserPostsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user : User!
    var posts : [Post] = []
    var userId = ""
    var delegate : HeaderProfileCollectionReusableViewDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("userId: \(userId)")
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchMyPosts()
    }
    
    func fetchUser(){
        Api.User.observeUser(withId: userId) { (user) in
            self.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                self.user = user
                self.navigationItem.title = user.username
                self.collectionView.reloadData()
            })
            
        }
    }
    
    func isFollowing(userId:String, completed:@escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed) //ERROR
    }
    
    func fetchMyPosts(){
        Api.MyPosts.fetchMyPosts(userId: userId) { (key) in
            Api.Post.observePost(withId: key, completion: {
                post in
                print(post.id)
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileUser_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}

extension ProfileUserPostsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostsCollectionViewCell", for: indexPath) as!
        UserPostsCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self //KINDA GUESSED
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
            headerViewCell.delegate = self.delegate
            headerViewCell.delegate2 = self
        }
        return headerViewCell
    }
}

extension ProfileUserPostsViewController: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC{
    func goToSettingVC() {
        performSegue(withIdentifier: "ProfileUser_SettingSegue", sender: nil)
    }
}

extension ProfileUserPostsViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2 - 2, height: collectionView.frame.size.width / 2 - 2)
    }
}

extension ProfileUserPostsViewController: UserPostsCollectionViewCellDelegate{
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier:"ProfileUser_DetailSegue", sender: postId)
    }
}


