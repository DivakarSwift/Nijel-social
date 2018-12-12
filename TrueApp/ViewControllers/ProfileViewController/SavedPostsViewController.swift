//
//  SavedPostsViewController.swift
//  Mine
//
//  Created by Nijel Hunt on 8/29/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SavedPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var posts = [Post]()
    var user : User!
    var REF_USERS = Database.database().reference().child("users")
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()        
        let nib = UINib(nibName: "SavedTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "kSavedTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts.removeAll()
        tableView.reloadData()
        
        observePosts(withId: (Auth.auth().currentUser?.uid)!) { (post) in
            self.tableView.reloadData()
        }
        
    }

    func observePosts(withId uid: String, completion: @escaping (Post) -> Void) {
        REF_USERS.child(uid).child("SavedPosts").observe(.value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as? DataSnapshot
                let snapKey = snap!.key as String
                let dict = snap?.value as! [String: Any]
                print(snapKey)
                let post = Post.transformPostPhoto(dict: dict, key: snapKey)
                self.posts.append(post)
                completion(post)
            }
        })
    }
    
    func observeAvatar(withId uid: String, completion: @escaping (String) -> Void) {
        REF_USERS.child(uid).child("profileImageUrl").observe(.value, with: { snapshot in
            let avatar = snapshot.value as! String
            completion(avatar)
        })
    }
    
    
    func downloadImages(folderPath: String, success:@escaping (_ image:UIImage)->(),failure:@escaping (_ error:Error)->()){
            // Create a reference with an initial file path and name
            let reference = Storage.storage().reference(withPath: folderPath)
            reference.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let _error = error{
                    print(_error)
                    failure(_error)
                } else {
                    if let _data  = data {
                        let myImage:UIImage! = UIImage(data: _data)
                        success(myImage)
                    }
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = Date(timeIntervalSince1970: posts[indexPath.row].date!)
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let cell = tableView.dequeueReusableCell(withIdentifier: "kSavedTableViewCell", for: indexPath) as! SavedTableViewCell
        if (indexPath.row + 1) % 2 == 0 {
            cell.backgroundColor = UIColor(red: 1, green: 0.988, blue: 0.841, alpha: 1)
        }
        cell.descLabel.text = posts[indexPath.row].whoPosted! + " | " + String(describing: month) + "/" + String(describing: day) + "/" + String(describing: year)
        //cell.descLabel.text.font
        //cell.userName.text = posts[indexPath.row].whoPosted! + "     | "
//        cell.descLabel.text = posts[indexPath.row].text!
        //cell.timeLabel.text = String(describing: month) + "/" + String(describing: day) + "/" + String(describing: year)
        if let url = posts[indexPath.row].imgURL {
            self.downloadImages(folderPath: url, success: { (img) in
                cell.postImg.image = img
            }, failure: { (err) in
                
            })
        }
        let id = posts[indexPath.row].postFromUserId
        observeAvatar(withId: id!) { (avatar) in
            self.downloadImages(folderPath: avatar, success: { (img) in
                cell.avatarLabel.image = img
            }, failure: { (err) in
            
            })
        }
       
        //cell.avatarLabel.image = posts[indexPath.row].image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        var image = UIImage()
        if let cell = tableView.cellForRow(at: indexPath) as? SavedTableViewCell {
            image = cell.postImg.image ?? UIImage()
        }
        let vc = PostViewController.instantiate(post: post, commentatorImage: image , postImage: image )
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
