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
import MessageUI

enum UserPostsViewControllerType {
    case myPosts, notMyPosts
}

class UserPostsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    // MARK: - Outles
    
    @IBOutlet weak var lifeStoryButton: UIButton!
    @IBOutlet weak var lifeStoryTextView: UITextView!
    @IBOutlet weak var activationButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var segmentControll: UISegmentedControl?
    
    var activationCode = "not_active"
    var user : User!
    var image: UIImage?
    
    var showSelfPosts = true
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var type: UserPostsViewControllerType!
    var posts = [Post]()
    var lifeStoryText = ""
    var last24hoursPosts = [Post]()
    var byographyPosts = [Post]()
    var filteredPosts = [Post]()
    var isFilteredByDate = false
    lazy var datePicker = DatePickerView.fromNib(name: "DatePickerView") as! DatePickerView
    
    let date = Date().timeIntervalSince1970 - 24*60*60.0
    
    
    class func instantiate(user: User,type: UserPostsViewControllerType) -> UserPostsViewController {
        let vc = StoryboardControllerProvider<UserPostsViewController>.controller(storyboardName: "Home")!
        vc.type = type
        vc.user = user
        return vc
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    
    
    @IBAction func activateUser(_ sender: UIButton) {
        let alert = UIAlertController(title: "Verify profile", message: "Please enter user contact info", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Mobile # or Email"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if !self.isValidEmail(testStr: textField.text!) {
                self.alertWrongEmail()
            } else {
                let email = textField.text
                self.sendEmail(email: email!)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            var usersArr = [String]()
            usersArr.append(email)
            mail.setToRecipients(usersArr)
            mail.setSubject("Knocknock Invitation Code")
            let code = randomString(length: 8)
            self.activationCode = code
            mail.setMessageBody("<p>Knocknock, who's there? Well many of our friends are, and I've created your account for you. Download the app Knocknock and use this invitation code to retrieve and verify the profile that was made for you. Your invitation code: <b> \(code) </b> </p>", isHTML: true)
            present(mail, animated: true)
            // CHECK MSG STATUS - IF SUCCESS - ADD TO BD
        } else {
            // show failure alert
        }
    }

    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(user.id!)
        if result.rawValue == 0 {
            self.activationCode = "not_active"
        }
        newUserReference.updateChildValues(["activationCode": self.activationCode])
        controller.dismiss(animated: true)

    }
    
    func alertWrongEmail() {
        let alert = UIAlertController(title: "Warning", message: "Wrong email", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editLifeStoryAction(_ sender: UIButton) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        print("EDIT STORY")
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        try! Auth.auth().signOut()
        let vc = LaunchScreenViewController.instantiate()
        self.present(vc, animated: false, completion: nil)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchPosts()
        collectionView.dataSource = self
        collectionView.delegate = self
        //super.viewWillAppear(animated)
       // posts.removeAll()
        collectionView.reloadData()
        UserDefaults.standard.set(false, forKey: "isEditStory")
        Api.User.observeUser(withId: user.id!, completion: { (user) in
            self.user = user
            self.fetchPosts()
            self.fetchUser()
        })
        if type == .notMyPosts {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
            navigationItem.setLeftBarButton(backButton, animated: true)
        }
        collectionView.register(UINib(nibName: "HomePageSmallPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageSmallPostCollectionViewCell")
        collectionView.register(UINib(nibName: "HomePageBigPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageBigPostCollectionViewCell")
        collectionView.register(UINib(nibName: "CreateByographyPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateByographyPostCollectionViewCell")
        collectionView.register(UINib(nibName: "TextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextCollectionViewCell")


        
    }
    

    @objc func keyboardWillShow(sender: NSNotification) {
        //self.view.frame.origin.y -= 250
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        //self.view.frame.origin.y += 250
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
    
    @IBAction func saveLifeAction(_ sender: Any) {
        
        let isEditStory = UserDefaults.standard.bool(forKey: "isEditStory")
        print(isEditStory)

            let editStory = UserDefaults.standard.bool(forKey: "isEditStory")
            print(editStory)
            if (editStory) {
                collectionView.reloadData()
            }
    }
    
    func fetchPosts() {
        if let dict = user?.myPosts {
            posts.removeAll()
            for i in dict {
                let post = Post.transformPostPhoto(dict: i.value, key: i.key)
                if showSelfPosts {
                    posts.append(post)
                } else {
                    if post.postFromUserId != Auth.auth().currentUser?.uid {
                        posts.append(post)
                    }
                }
            }

            posts.sort(by: { $0.date ?? 0 > $1.date ?? 0 })
            last24hoursPosts.removeAll()
            for post in posts where post.date! >= date {//where post.isWatchedByUser == false

                if showSelfPosts {
                    last24hoursPosts.append(post)
                } else {
                    if post.postFromUserId != user.id {
                        last24hoursPosts.append(post)
                    }
                }
            }
            byographyPosts.removeAll()
            for post in posts where post.date! < date { //where post.isWatchedByUser != false
                if showSelfPosts {
                    byographyPosts.append(post)
                } else {
                    if post.postFromUserId != user.id {
                        byographyPosts.append(post)
                    }
                }
            }
            byographyPosts.sort(by: {$0.contentDate ?? $0.date ?? 0 < $1.contentDate ?? $1.date ?? 0 })
        }
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let vc = CreatePostViewController.instantiate(user: user, type: .notByographyPost)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func switchPosts(_ sender: UISwitch) {
        if (sender.isOn){ // && user.id == Auth.auth().currentUser?.uid
            showSelfPosts = true
            fetchPosts()
        } else {
            showSelfPosts = false
            fetchPosts()
        }
        collectionView.reloadData()
    }
    
    @IBAction func segmentControllValueChanged(_ sender: UISegmentedControl) {
        collectionView.reloadData()
    }
    
    func showDatePickerFilter() {
        datePicker.frame = view.frame
        datePicker.alpha = 0
        datePicker.center = view.center
        datePicker.datePicker.maximumDate = Date()
        view.addSubview(datePicker)
        datePicker.applyButton.addTarget(self, action: #selector(removeDatePicker), for: .touchUpInside)
        UIView.animate(withDuration: 0.3) {
            self.datePicker.alpha = 1
        }
    }
    
    @objc func removeDatePicker() {
        filterWith(date: datePicker.datePicker.date)
        UIView.animate(withDuration: 0.3,
                       animations: { self.datePicker.alpha = 0 },
                       completion: { completed in
                        if completed == true {
                            self.datePicker.removeFromSuperview()
                        }
        })
    }
    
    func filterWith(date: Date) {
        filteredPosts = posts.filter { post in
            let postDate = Date(timeIntervalSince1970: post.contentDate!)
            let calendar = Calendar.current
            let components: Set<Calendar.Component> = [.day, .month, .year]
            print(calendar.dateComponents(components, from: postDate), calendar.dateComponents(components, from: date))
            return calendar.dateComponents(components, from: postDate).day == calendar.dateComponents(components, from: date).day &&
                calendar.dateComponents(components, from: postDate).month == calendar.dateComponents(components, from: date).month &&
                calendar.dateComponents(components, from: postDate).year == calendar.dateComponents(components, from: date).year
        }
        collectionView.reloadData()
    }
    
    private func time(from timeInterval: Double) -> String {
        let time = Int(timeInterval)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)%24
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
        return str
    }
}

extension UserPostsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControll?.selectedSegmentIndex == 0 {
            if Auth.auth().currentUser?.uid == user.id {
                return last24hoursPosts.count + byographyPosts.count
            } else {
                return last24hoursPosts.count + 1 + byographyPosts.count
            }
        } else {
            if isFilteredByDate {
                return filteredPosts.count
            }
            return posts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segmentControll?.selectedSegmentIndex == 0 {
            if indexPath.row > last24hoursPosts.count || (indexPath.row >= last24hoursPosts.count && Auth.auth().currentUser?.uid == user.id) {
                if Auth.auth().currentUser?.uid == user.id {
                    if byographyPosts[indexPath.row - last24hoursPosts.count].imgURL == nil {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCollectionViewCell", for: indexPath) as!
                        TextCollectionViewCell
                        cell.label.text = byographyPosts[indexPath.row - last24hoursPosts.count].text ?? ""
                        return cell
                    }
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageSmallPostCollectionViewCell", for: indexPath) as!
                    HomePageSmallPostCollectionViewCell
                    cell.usernameLabel.text = (byographyPosts[indexPath.row - last24hoursPosts.count].whoPosted ?? "") + " |"
                    var text = time(from: byographyPosts[indexPath.row - last24hoursPosts.count].contentDate ?? byographyPosts[indexPath.row - last24hoursPosts.count].date!)
                    text.removeLast(3)
                    cell.label.text = text
                    cell.leftImageView.image = byographyPosts[indexPath.row - last24hoursPosts.count].image
                    cell.post = byographyPosts[indexPath.row - last24hoursPosts.count]
                    return cell
                }
                if byographyPosts[indexPath.row - last24hoursPosts.count - 1].imgURL == nil {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCollectionViewCell", for: indexPath) as!
                    TextCollectionViewCell
                    cell.label.text = byographyPosts[indexPath.row - last24hoursPosts.count - 1].text ?? ""
                    return cell
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageSmallPostCollectionViewCell", for: indexPath) as!
                HomePageSmallPostCollectionViewCell
                cell.usernameLabel.text = (byographyPosts[indexPath.row - last24hoursPosts.count - 1].whoPosted ?? "")
                var text = time(from: byographyPosts[indexPath.row - last24hoursPosts.count - 1].contentDate ?? byographyPosts[indexPath.row - last24hoursPosts.count - 1].date!)
                text.removeLast(3)
                cell.label.text = text
                cell.leftImageView.image = byographyPosts[indexPath.row - last24hoursPosts.count - 1].image
                cell.post = byographyPosts[indexPath.row - last24hoursPosts.count - 1]
                return cell
            }
            
            if indexPath.row == last24hoursPosts.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateByographyPostCollectionViewCell", for: indexPath) as! CreateByographyPostCollectionViewCell
                cell.closure = {
                    self.navigationController?.pushViewController(CreatePostViewController.instantiate(user: self.user, type: .byographyPost), animated: true)
                }
                return cell
            }
            if last24hoursPosts[indexPath.row].date! >= date {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageBigPostCollectionViewCell", for: indexPath) as!
                HomePageBigPostCollectionViewCell
                cell.topLabel.text = (last24hoursPosts[indexPath.row].whoPosted! + " | " + time(from: last24hoursPosts[indexPath.row].date!))
                cell.postImageView.image = last24hoursPosts[indexPath.row].image
                cell.label.text = last24hoursPosts[indexPath.row].text
                if type == .myPosts {
                    let database = Database.database().reference().child("users")
                    let post = last24hoursPosts[indexPath.row]
                    if user.id == Auth.auth().currentUser?.uid {
                        database.child(user.id!).child("myPosts").child(post.id!).child("isWatchedByUser").setValue(true)
                    }
                }
                cell.post = last24hoursPosts[indexPath.row]
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageSmallPostCollectionViewCell", for: indexPath) as!
                HomePageSmallPostCollectionViewCell
                cell.usernameLabel.text = last24hoursPosts[indexPath.row].whoPosted! + " |"
                var text = time(from: last24hoursPosts[indexPath.row].date!)
                text.removeLast(3)
                cell.label.text = text
                cell.leftImageView.image = last24hoursPosts[indexPath.row].image
                cell.post = last24hoursPosts[indexPath.row]
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPostsCollectionViewCell", for: indexPath) as!
            UserPostsCollectionViewCell
            if isFilteredByDate {
                let post = filteredPosts[indexPath.row]
                cell.post = post
            } else {
                let post = posts[indexPath.row]
                cell.post = post
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,  viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
            if let user = self.user {
                headerViewCell.user = user
                if let image = self.image {
                    headerViewCell.profileImage.image = image
                }
                var postCount = 0
                for post in posts {
                    if post.postToUserId == user.id {
                        postCount += 1
                        print(postCount)
                    }
                }
                headerViewCell.isFilteredByDate = isFilteredByDate
                headerViewCell.myPostsCountLabel.text = "\(postCount)"
                headerViewCell.dateFilterButton.setTitle(isFilteredByDate ?  "Clear" : "Filter by Date", for: .normal)

                headerViewCell.delegate = self
            }
            
            if type == .notMyPosts {
                //headerViewCell.segmentControll.isHidden = true
                // headerViewCell.createPost.isHidden = false
            }
            headerViewCell.createPost.layer.cornerRadius = 8
//            if Auth.auth().currentUser?.uid == user.id {
//                headerViewCell.createPost.isHidden = true
//            }
            segmentControll = headerViewCell.segmentControll
            activityIndicator.frame = CGRect(x: headerViewCell.profileImage.frame.width/2, y: headerViewCell.profileImage.frame.height/2, width: 36, height: 36)
            activityIndicator.hidesWhenStopped = true
            headerViewCell.profileImage.addSubview(activityIndicator)
            return headerViewCell
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath) as! FooterProfileCollectionReusableView
            lifeStoryText = footerView.lifeStoryTextView.text
            if let user = self.user {
                footerView.user = user
            }
            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
        
        
    }
}

// MARK: CollectionViewFlowLayout

extension UserPostsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let textHeight = lifeStoryText.height(withConstrainedWidth: collectionView.frame.size.width - 2 - 20, font: UIFont.systemFont(ofSize: 14))
        print(textHeight)
        return CGSize(width: collectionView.frame.size.width, height: textHeight + 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if segmentControll?.selectedSegmentIndex == 0 {
            if indexPath.row > last24hoursPosts.count {
                return CGSize(width: collectionView.frame.size.width - 2, height: 65)
            }
            if indexPath.row == last24hoursPosts.count {
                if Auth.auth().currentUser?.uid == user.id {
                    return CGSize(width: collectionView.frame.size.width - 2, height: 65)
                }
                return CGSize(width: collectionView.frame.size.width - 2, height: 40)
            }
            if last24hoursPosts[indexPath.row].date! >= date {
                let text = last24hoursPosts[indexPath.row].text ?? ""
                    return CGSize(width: collectionView.frame.size.width - 2, height: 555 + text.height(withConstrainedWidth: collectionView.frame.size.width - 2 - 20, font: UIFont.systemFont(ofSize: 17)))
            } else {
                return CGSize(width: collectionView.frame.size.width - 2, height: 65)
            }
        } else {
            return CGSize(width: collectionView.frame.size.width / 2 - 2, height: collectionView.frame.size.width / 2 - 2)
        }
    }
}

// MARK: - CollectionViewDelegate

extension UserPostsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var post: Post
         var image: UIImage?
        if segmentControll?.selectedSegmentIndex == 0{
            if indexPath.row > last24hoursPosts.count{
                post = byographyPosts[indexPath.row - last24hoursPosts.count - 1]
                if Auth.auth().currentUser?.uid == user.id {
                    post = byographyPosts[indexPath.row - last24hoursPosts.count]
                    
                }
            }else if indexPath.row == last24hoursPosts.count && Auth.auth().currentUser?.uid == user.id {
                post = byographyPosts[indexPath.row - last24hoursPosts.count]
            }else if last24hoursPosts[indexPath.row].isWatchedByUser == false && indexPath.row != last24hoursPosts.count {
                post = last24hoursPosts[indexPath.row]
                
            } else {
                return
            }
        } else {
            post = posts[indexPath.row]
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? HomePageBigPostCollectionViewCell{
            image = cell.postImageView.image
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? HomePageSmallPostCollectionViewCell{
            image = cell.leftImageView.image
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? UserPostsCollectionViewCell{
            image = cell.photo.image
        }
        
        let vc = PostViewController.instantiate(post: post, commentatorImage: image ?? UIImage(), postImage: image ?? UIImage())
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UserPostsViewController: HeaderProfileCollectionReusableViewDelegate {
    // TODO: remove this
    func updateFollowButton(forUser user: User) {
    
    }
    
    func goToSettingVC() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingTableViewController")
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func showDateFilter() {
        isFilteredByDate = !isFilteredByDate
        if isFilteredByDate {
            showDatePickerFilter()
        } else {
            collectionView.reloadData()
        }
    }
}


