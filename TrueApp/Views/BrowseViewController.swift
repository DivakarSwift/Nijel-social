//
//  BrowseViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/8/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import ProgressHUD

class BrowseViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var posts : [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        loadTopPosts()
    }
    
    @IBAction func refreshButton_TouchUpInside(_ sender: Any) {
        loadTopPosts()
    }
    
      func loadTopPosts(){
        //ProgressHUD.show("Loading...", interaction: false)
        self.posts.removeAll()
        self.collectionView.reloadData()
        Api.Post.observeTopPosts { (post) in
            self.posts.append(post)
            self.collectionView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Browse_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}

extension BrowseViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseCollectionViewCell", for: indexPath) as!
        UserPostsCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    
}

extension BrowseViewController: UICollectionViewDelegateFlowLayout{
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

extension BrowseViewController: UserPostsCollectionViewCellDelegate{
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Browse_DetailSegue", sender: postId)
    }
}
