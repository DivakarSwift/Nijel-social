//
//  TrueFeedViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/2/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class TrueFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var REF_FOLLOWING = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("following")
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    //let refreshControl = UIRefreshControl()
    
    var posts = [Post]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "HomePageBigPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageBigPostCollectionViewCell")
        posts.removeAll()
        collectionView.reloadData()
        //        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        //        tableView.addSubview(refreshControl)
        getFollowers { (completion) in
            self.loadFeed(id: completion) { (Post) in
                print(self.posts.count)
                self.collectionView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //    @objc func refresh() {
    //        self.posts.removeAll()
    //        self.users.removeAll()
    //        loadFeed(id: String, completion: (Post) -> Void)
    //    }
    
    func getFollowers(completed: @escaping (String) -> Void) {
        
        REF_FOLLOWING.child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: {
            snapshot in
            for child in snapshot.children {
                let snap = child as? DataSnapshot
                let snapKey = snap!.key as String
                completed(snapKey)
            }
        })
    }
    
    func loadFeed(id: String, completion: @escaping (Post) -> Void) {
        _ = Database.database().reference().child("users").child(id).child("myPosts").observe(.value, with: { snapshot in
            //self.posts.removeAll()
            for child in snapshot.children {
                let snap = child as? DataSnapshot
                let snapKey = snap!.key as String
                let dict = snap?.value as! [String: Any]
                
                let post = Post.transformPostPhoto(dict: dict, key: snapKey)
                _ = Date().timeIntervalSince1970
                if post.postToUserId == id  {//&& post.date! + 86400.0 > hours
                    //self.posts.append(post)
                    self.posts.insert(post, at: 0)
                }
                else if post.postFromUserId == id  {//&& post.date! + 86400.0 > hours
                    self.posts.insert(post, at: 0)
                    //self.posts.append(post)
                } //for some reason doesnt get posts to profiles (no users)
                completion(post)
            }
            //need to correct this
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageBigPostCollectionViewCell", for: indexPath) as!
        HomePageBigPostCollectionViewCell
        
        cell.topLabel.text = (posts[indexPath.row].whoPosted! )
            //+ " | " + time(from: posts[indexPath.row].date!)) //make the | centered
        cell.timeLabel.text = time(from: posts[indexPath.row].date!)
        cell.postImageView.image = posts[indexPath.row].image
        cell.storyLabel.text = posts[indexPath.row].text
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = posts[indexPath.row].text ?? ""
        return CGSize(width: collectionView.frame.size.width - 2, height: 555 + text.height(withConstrainedWidth: collectionView.frame.size.width - 2 - 20, font: UIFont.systemFont(ofSize: 17)))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        var image: UIImage?
        if let cell = collectionView.cellForItem(at: indexPath) as? HomePageBigPostCollectionViewCell {
            image = cell.postImageView.image
        }
        let vc = PostViewController.instantiate(post: post, commentatorImage: image ?? UIImage(), postImage: image ?? UIImage())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func time(from timeInterval: Double) -> String {
        let time = Int(timeInterval)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)%24 //makes 12:30 am == 0:30 am
        var str = ""
        if hours > 12 {
            if minutes < 10 {
                str = "\(hours - 12):0\(minutes) pm"
            } else {
                str = "\(hours - 12):\(minutes) pm"
            }
        } else {
            if minutes < 10 {
                str = "\(hours):0\(minutes) am"
            } else {
                str = "\(hours):\(minutes) am"
            }
        }
        
        if hours == 0{
            str = "12: 0\(minutes) pm"
        }
        return str
    }
}

