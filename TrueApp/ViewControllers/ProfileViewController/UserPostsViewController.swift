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
import ProgressHUD

enum UserPostsViewControllerType {
    case myPosts, notMyPosts
}

class UserPostsViewController: UIViewController, MFMailComposeViewControllerDelegate, CreatePostDelegate {

    func response(madePost: Bool) {
        print("response called.")
        if madePost{
            loadData()
        }
    }
    
    func updateUserPostsView(changedInfo:Bool){
        print("updateUserPostsView called.")
        if changedInfo{
            loadData()
        }
    }
    
    
    // MARK: - Outles
    
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet weak var lifeStoryButton: UIButton!
    @IBOutlet weak var lifeStoryTextView: UITextView!
    @IBOutlet weak var activationButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UserPostsCollectionViewCell!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createPostButton: UIButton!
    weak var segmentControll: UISegmentedControl?
    lazy var refreshControl = UIRefreshControl()
    
    var activationCode = "not_active"
    var user : User! {
        didSet {
            if user.id == Auth.auth().currentUser?.uid {
                infoButton.isEnabled = false
            }
        }
    }
    var isSettingsVCOpened = false
    var image: UIImage?
    var headerHeight: CGFloat = 567
    var showSelfPosts = true
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    var type: UserPostsViewControllerType!
    var posts = [Post]()
    var lifeStoryText = ""
    var last24hoursPosts = [Post]()
    var filteredPosts = [Post]()
    var isFilteredByDate = false
    let expandableTitles: [(ExpandableTextCell.ExpandableCellType, String)] = [(ExpandableTextCell.ExpandableCellType.earlyLife, "Early Life"),
                                                                               (.education, "Education"),
                                                                               (.career, "Career"),
                                                                               (.personalLife, "Personal Life"), (.hobbies, "Hobbies")]
    var expandedCellIndexes: [Int] = []
    lazy var datePicker = DatePickerView.fromNib(name: "DatePickerView") as! DatePickerView
    lazy var userApi = UserApi()
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
    
    func getAdditionalInfo(by type: ExpandableTextCell.ExpandableCellType) -> String? {
        switch type {
        case .career:
            return user.career
        case .earlyLife:
            return user.earlyLife
        case .education:
            return user.education
        case .personalLife:
            return user.personalLife
        case .hobbies:
            return user.hobbies
        }
        //might have to add the information about who edited profile here
    }
    
    func updateAdditionalUserInfo(by type: ExpandableTextCell.ExpandableCellType, with text: String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        _ = usersReference.child(user.id!)
        Database.database().reference().child("users").child(user!.id!).updateChildValues([type.rawValue : text])
        
        switch type {
        case .career:
            user.career = text
        case .earlyLife:
            user.earlyLife = text
        case .education:
            user.education = text
        case .personalLife:
            user.personalLife = text
        case .hobbies:
            user.hobbies = text
        }
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

    
    @IBAction func infoButtonTouched(_ sender: Any) {

        let alert = UIAlertController(title: nil, message: "Choose option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: {_ in
            ProgressHUD.show()
            Api.User.blockUser(userID: self.user.id!, completion: { error in
                
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else {
                    ProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "Completed", message: "User has been blocked", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    // self.present(alertController, animated: true, completion: nil)
                    ProgressHUD.dismiss()
                } //if user already blocked, change to "Unblock User" and take out of blocked users (.remove)
            })
        }))
        alert.addAction(UIAlertAction(title: "Flag user", style: .destructive, handler: {_ in
            ProgressHUD.show()
            Api.User.flagUser(userID: self.user.id!) { error in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                } else {
                    ProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "Completed", message: "User has been flagged", preferredStyle: UIAlertController.Style.alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    ProgressHUD.dismiss()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in alert.dismiss(animated: true)}))
        self.present(alert, animated: true)
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
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if isSettingsVCOpened {
            loadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        collectionView.register(UINib(nibName: "HeaderProfileCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView")
        collectionView.register(UINib(nibName: "ExpandableTextCell", bundle: nil), forCellWithReuseIdentifier: "ExpandableTextCell")
        collectionView.register(UINib(nibName: "HomePageSmallPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageSmallPostCollectionViewCell")
        collectionView.register(UINib(nibName: "HomePageBigPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomePageBigPostCollectionViewCell")
        collectionView.register(UINib(nibName: "CreateByographyPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateByographyPostCollectionViewCell")
        collectionView.register(UINib(nibName: "TextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextCollectionViewCell")
        collectionView.reloadData()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc func loadData() {

        UserDefaults.standard.set(false, forKey: "isEditStory")
        
        ProgressHUD.show()
        Api.User.observeUser(withId: user.id!, completion: { (user) in
            ProgressHUD.dismiss()
            self.user = user
            self.fetchPosts()
            self.fetchUser()
            self.collectionView.reloadData()
            //self.user.fullName = user.fullName
        })
        if type == .notMyPosts {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
            navigationItem.setLeftBarButton(backButton, animated: true)
        }
        refreshControl.endRefreshing()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgSizeValue  {
            collectionView.contentInset.bottom = keyboardSize.height - 150
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        collectionView.contentInset.bottom = 0
    }
    
    @objc func refresh() {
        self.posts.removeAll()
        loadData()
    }
    
    func fetchUser() {
            self.navigationItem.title = user.username //limit of 15 characters
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
        Api.User.isUserBlockedMe(userID: user.id!) { [weak self] hasBlockedMe in
            if hasBlockedMe {
                self!.createPostButton.isHidden = true
                return }
            guard let `self` = self else { return }
            defer {
                self.collectionView.reloadData()
            }
            self.posts.removeAll()
            self.last24hoursPosts.removeAll()
            //edit buttons are hidden
            if let dict = self.user?.myPosts {
                for i in dict {
                    let post = Post.transformPostPhoto(dict: i.value, key: i.key)
                    if self.showSelfPosts {
                        self.posts.append(post)
                    } else {
                        if post.postFromUserId != self.user.id {
                            self.posts.append(post)
                        }
                    }
                }
                
                self.posts.sort(by: { $0.date ?? 0 > $1.date ?? 0 })
                for post in self.posts where post.date != nil && post.date! >= self.date {//where post.isWatchedByUser == false
                    
                    if self.showSelfPosts {
                        self.last24hoursPosts.append(post)
                    } else {
                        if post.postFromUserId != self.user.id {
                            self.last24hoursPosts.append(post)
                        }
                    }
                }
            }
        }
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let vc = CreatePostViewController.instantiate(user: user, type: .notByographyPost, parentClass: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func switchPosts(_ sender: UISwitch) {
        if (sender.isOn){ // && user.id == Auth.auth().currentUser?.uid
            showSelfPosts = false
            fetchPosts()
        } else {
            showSelfPosts = true
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
                if hours == 0{
                    str = "12:\(minutes) pm"
                }
            } else {
                str = "\(hours - 12):\(minutes) pm"
                if hours == 0{
                    str = "12:\(minutes) pm"
                }
            }
        } else {
            if minutes < 10 {
                str = "\(hours):0\(minutes) am"
                if hours == 0{
                    str = "12:\(minutes) am"
                }
            } else {
                str = "\(hours):\(minutes) am"
                if hours == 0{
                    str = "12:\(minutes) am"
                }
            }
        }
        
        //        if hours == 0{
        //            str = "12: \(minutes) pm"
        //        }
        
        return str
    }
}


extension UserPostsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return expandableTitles.count
        }
        if segmentControll?.selectedSegmentIndex == 0 {
            if Auth.auth().currentUser?.uid == user.id {
                return last24hoursPosts.count
            } else {
                return last24hoursPosts.count + 1
            }
        } else {
            if isFilteredByDate {
                return filteredPosts.count
            }
            return posts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpandableTextCell", for: indexPath) as! ExpandableTextCell
            cell.titleLabel.text = expandableTitles[indexPath.row].1
            cell.cellType = expandableTitles[indexPath.row].0
            cell.isExpanded = !expandedCellIndexes.contains(indexPath.row)
            cell.delegate = self
            cell.setupWithModel()
            if let attributedString = getAdditionalInfo(by: cell.cellType)?.unarchiveWithUserIds() {
                cell.textEdit.attributedText = attributedString
            }
            cell.textEdit.delegate = cell
            if cell.textEdit.attributedText.string.count > 0 && getAdditionalInfo(by: cell.cellType)?.unarchiveWithUserIds().string.count ?? 0 > 0 {
                print("☝️ --- text edit attributes \(cell.textEdit.attributedText?.attributes(at: 0, effectiveRange: nil))")
                print("☝️ --- original attributes \(getAdditionalInfo(by: cell.cellType)?.unarchiveWithUserIds().attributes(at: 0, effectiveRange: nil))")
            }
            return cell
        }
        
        if segmentControll?.selectedSegmentIndex == 0 {
            
            if indexPath.row == last24hoursPosts.count { //for some reason, never gets this for user
                print("should have Life Story")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateByographyPostCollectionViewCell", for: indexPath) as! CreateByographyPostCollectionViewCell
                cell.closure = {
                 //   self.navigationController?.pushViewController(CreatePostViewController.instantiate(user: self.user, type: .byographyPost), animated: true)
                }
                return cell
            }
            if last24hoursPosts[indexPath.row].date! >= date {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageBigPostCollectionViewCell", for: indexPath) as!
                HomePageBigPostCollectionViewCell
                cell.topLabel.text = (last24hoursPosts[indexPath.row].whoPosted!)
                    //+ " | " + time(from: last24hoursPosts[indexPath.row].date!))
                cell.timeLabel.text = time(from: posts[indexPath.row].date!)
                cell.postImageView.image = last24hoursPosts[indexPath.row].image
                cell.storyLabel.text = last24hoursPosts[indexPath.row].text
                cell.delegate = self
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
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
                headerViewCell.viewDidLoad()
                headerViewCell.isFilteredByDate = isFilteredByDate
                headerViewCell.myPostsCountLabel.text = "\(postCount)"
                headerViewCell.dateFilterButton.setTitle(isFilteredByDate ?  "Clear" : "Filter by Date", for: .normal)

                headerViewCell.delegate = self
            }
            headerViewCell.activateButton.addTarget(self, action: #selector(activateUser), for: .touchUpInside)
            headerViewCell.filterSwitch.addTarget(self, action: #selector(switchPosts(_:)), for: .valueChanged)
            segmentControll = headerViewCell.segmentControll
            segmentControll?.addTarget(self, action: #selector(segmentControllValueChanged(_:)), for: .valueChanged)
            activityIndicator.frame = CGRect(x: headerViewCell.profileImage.frame.width/2, y: headerViewCell.profileImage.frame.height/2, width: 36, height: 36)
            activityIndicator.hidesWhenStopped = true
            headerViewCell.profileImage.addSubview(activityIndicator)
            
            return headerViewCell
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

// MARK: CollectionViewFlowLayout

extension UserPostsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize.zero
        }
        
        return CGSize(width: collectionView.frame.width, height: headerHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            if expandedCellIndexes.contains(indexPath.row) {
                let cell = collectionView.cellForItem(at: indexPath) as? ExpandableTextCell
                return CGSize(width: collectionView.frame.width, height: (cell?.textEdit.contentSize.height  ?? 205) + 60 )
            } else {
                return CGSize(width: collectionView.frame.width, height: 40)
            }
        }
        
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
        
        if indexPath.section == 1 {
            
            if expandedCellIndexes.contains(indexPath.row) {
                expandedCellIndexes = expandedCellIndexes.filter { return $0 != indexPath.row }
            } else {
                expandedCellIndexes.append(indexPath.row)
            }
            collectionView.reloadSections([indexPath.section])
            return
        }
        
        var post: Post
         var image: UIImage?
        if segmentControll?.selectedSegmentIndex == 0 {
          if last24hoursPosts[indexPath.row].isWatchedByUser == false && indexPath.row != last24hoursPosts.count {
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
        isSettingsVCOpened = true
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
    
    func showUpdateFrameHeight(to height: CGFloat) {
        headerHeight = height
        collectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
    }
}

extension UserPostsViewController: ExpandableTextCellDelegate {
    func textDidEndEditing(_ text: String, type: ExpandableTextCell.ExpandableCellType) {
        updateAdditionalUserInfo(by: type, with: text)
    }
}

extension UserPostsViewController: HomePageBigPostCollectionViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        
    }
    
    func goToProfileUserVC(userId: String) {
        ProgressHUD.show()
        userApi.observeUser(withId: userId) { [weak self] user in
            ProgressHUD.dismiss()
            guard let `self` = self else { return }
            let vc = UserPostsViewController.instantiate(user: user, type: .notMyPosts)
            vc.user = user
            vc.type = .notMyPosts
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
