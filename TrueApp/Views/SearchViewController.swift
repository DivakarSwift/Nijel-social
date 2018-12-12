//
//  TrueSearchViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/8/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchBar = UISearchBar()
    var users: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self as UISearchBarDelegate //ERROR for some reason
        searchBar.searchBarStyle = .minimal //or .prominent
        searchBar.placeholder = "Real Name or Username"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        
        doSearch()
    }
    
    func doSearch(){
        if (searchBar.text?.lowercased()) != nil{
            self.users.removeAll()
            self.tableView.reloadData()
//            Api.User.queryUsers(withText: searchText) { (user) in
//                self.isFollowing(userId: user.id!, completed: { (value) in
//                    user.isFollowing = value
//                    self.users.append(user)
//                    self.tableView.reloadData()
//                }) //when return/go button is touched, dismiss keyboard
//            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    func isFollowing(userId:String, completed:@escaping (Bool) -> Void){
        Api.Follow.isFollowing(userId: userId, completed: completed)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Search_ProfileSegue"{
//            let userPostsVC = segue.destination as! ProfileUserPostsViewController
//            let userId = sender as! String
//            userPostsVC.userId = userId
//            userPostsVC.delegate = self
//        }
//    }
}

extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        _ = users[indexPath.row]
        //cell.user = user
        return cell
    }
}

extension SearchViewController: HeaderProfileCollectionReusableViewDelegate {
    func showUpdateFrameHeight(to height: CGFloat) {
        
    }
    
    
    func showDateFilter() {
        
    }
    
    func goToSettingVC() {
        
    }
    // TODO: check is it works
    func updateFollowButton(forUser user: User) {
        for u in self.users{
            if u.id == user.id{
                u.followingSet = user.followingSet
                self.tableView.reloadData()
            }
        }
    }
}


