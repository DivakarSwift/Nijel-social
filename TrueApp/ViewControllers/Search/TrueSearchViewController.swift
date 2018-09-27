//
//  TrueSearchViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/8/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import ProgressHUD

class TrueSearchViewController: UIViewController {

    var searchBar = UISearchBar()
    var users: [User] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSettings()
    }
    
    func setSettings() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Real Name or Username"
        searchBar.frame.size.width = view.frame.size.width - 60
        searchBar.autocapitalizationType = .none
        searchBar.enablesReturnKeyAutomatically = false
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        tableView.register(UINib(nibName: "PeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "PeopleTableViewCell")
    }
    
    func search(searchText: String){
        Api.User.queryUsers(withText: searchText) {[weak self] users in
            self?.users = users
            self?.tableView.reloadData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func isFollowing(userId:String, completed:@escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed) 
    }
}

extension TrueSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if let text = searchBar.text, text != "" {
            search(searchText: text)
        } else {
            users.removeAll()
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
}

extension TrueSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        cell.updateView(user: user)
        cell.selectionStyle = .none
        return cell
    }
}

extension TrueSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserPostsViewController.instantiate(user: users[indexPath.row], type: .notMyPosts)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TrueSearchViewController: HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in self.users{
            if u.id == user.id{
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}


