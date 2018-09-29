//
//  CreatePostViewController.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 9/27/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

class CreatePostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    
    class func instantiate() -> CreatePostViewController {
        return StoryboardControllerProvider<CreatePostViewController>.controller(storyboardName: "CreatePostViewController")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CreatePostTableViewCell", bundle: nil), forCellReuseIdentifier: "CreatePostTableViewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let backButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(post))
        navigationItem.setRightBarButton(backButton, animated: true)
    }
    
    func btnClicked() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CreatePostTableViewCell {
                cell.postImageView.contentMode = .scaleAspectFit
                cell.postImageView.image = chosenImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgSizeValue  {
            var contentInsets: UIEdgeInsets
            if UIDevice.current.orientation == .portrait {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.height), right: 0.0);
            } else {
                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize.width), right: 0.0);
            }
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func post() {
        
    }
}

extension CreatePostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CreatePostTableViewCell") as? CreatePostTableViewCell {
            cell.completion = btnClicked
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
}

extension CreatePostViewController: UITableViewDelegate {
    
}
