//
//  FinalHomeViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/5/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

enum UserPostsViewControllerType {
    case myPosts, notMyPosts
}

class UserPostsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var createPostButton: UIButton!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    
    var user : User!
    var posts : [Post] = []
    var image: UIImage?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var type: UserPostsViewControllerType!
    
    class func instantiate(user: User,type: UserPostsViewControllerType) -> UserPostsViewController {
        let vc = StoryboardControllerProvider<UserPostsViewController>.controller(storyboardName: "Home")!
        vc.type = type
        vc.user = user
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchUser()
        fetchMyPosts()
        //createPostButton.layer.cornerRadius = 8
        if type == .notMyPosts {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
            navigationItem.setLeftBarButton(backButton, animated: true)
            //createPostButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func fetchUser() {
            self.navigationItem.title = user.username
            self.activityIndicator.startAnimating()
            let storage = Storage.storage()
            let spaceRef = storage.reference(forURL: "gs://first-76cc5.appspot.com/\(user.profileImageUrl!)")
            spaceRef.getData(maxSize: Int64.max) { [weak self] data, error in
                self?.activityIndicator.stopAnimating()
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = data else { return }
                self?.image = UIImage(data: data)
                self?.collectionView.reloadData()
            }
    }
    
    func fetchMyPosts(){
        guard let currentUser = Auth.auth().currentUser else{  
            return
        }
        Api.MyPosts.REF_MYPOSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            print(snapshot)
            Api.Post.observePost(withId: snapshot.key, completion: {
                post in
                print(post.id!)
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func segmentControllValueChanged(_ sender: UISegmentedControl) {
    }
}

extension UserPostsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostsCollectionViewCell", for: indexPath) as!
        UserPostsCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
            if let image = self.image {
                headerViewCell.profileImage.image = image
            }
        }
        activityIndicator.frame = CGRect(x: headerViewCell.profileImage.frame.width/2, y: headerViewCell.profileImage.frame.height/2, width: 36, height: 36)
        activityIndicator.hidesWhenStopped = true
        headerViewCell.profileImage.addSubview(activityIndicator)
        return headerViewCell
    }
}

extension UserPostsViewController: UICollectionViewDelegateFlowLayout {
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
