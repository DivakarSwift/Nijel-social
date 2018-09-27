//
//  PeopleViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/6/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
    }
    func loadUsers(){
        Api.User.observeUsers { (user) in
            self.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
        }
    func isFollowing(userId:String, completed:@escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed) 
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue"{
            let userPostsVC = segue.destination as! ProfileUserPostsViewController
            let userId = sender as! String
            userPostsVC.userId = userId
            userPostsVC.delegate = self
        }
    }
    }



extension PeopleViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        //cell.user = user
        return cell
    }
}

extension PeopleViewController: HeaderProfileCollectionReusableViewDelegate{
    func updateFollowButton(forUser user: User) {
        for u in self.users{
            if u.id == user.id{
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
