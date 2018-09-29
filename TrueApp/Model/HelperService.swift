//
//  HelperService.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/6/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseStorage
import ProgressHUD
import FirebaseAuth
import FirebaseDatabase
class HelperService{
    static func uploadDataToServer(data:Data, videoUrl: URL? = nil, ratio:CGFloat, story: String, onSuccess: @escaping () -> Void){
        if let videoUrl = videoUrl{
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, story: story, onSuccess: onSuccess)
                })
            })
            //self.sendDataToDatabase()
        } else{
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, story: story, onSuccess: onSuccess)
        }
        }
}
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void){
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
//            if let videoUrl = metadata?.downloadURL()?.absoluteString{ //StorageReference.downloadURL(completion:) {
//                onSuccess(videoUrl)
//            }
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void){
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil){ (metadata, error) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
//            if let photoUrl = metadata?.downloadURL()?.absoluteString{
//                onSuccess(photoUrl)
//            }
        }
    }
    
    static func sendDataToDatabase(photoUrl:String, videoUrl: String? = nil, ratio:CGFloat, story:String, onSuccess: @escaping () -> Void){
        let newPostId = Api.Post.REF_POSTS.childByAutoId().key
        let newPostReference = Api.Post.REF_POSTS.child(newPostId ?? "")
        
        guard let currentUser = Auth.auth().currentUser else{
            return
        }
        let currentUserId = currentUser.uid 
        
        let timestamp = Int(Date().timeIntervalSince1970)
        //print(timestamp)
        
        var dict = ["uid": currentUserId, "photoUrl":photoUrl, "caption": story, "likeCount": 0, "ratio": ratio, "timestamp": timestamp] as [String:Any]
        
        if let videoUrl = videoUrl{
            dict["videoUrl"] = videoUrl
        
        newPostReference.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            Api.Feed.REF_FEED.child(Auth.auth().currentUser!.uid).child(newPostId ?? "").setValue(true)
            Api.Follow.REF_FOLLOWERS.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    print(child.key)
                    Api.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)" :true])
                    let newNotificationId = Api.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificationReference = Api.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId ?? "")
                    newNotificationReference.setValue(["from" : Auth.auth().currentUser!.uid, "type": "feed", "objectId": newPostId, "timestamp": timestamp])
                })
            })
            let myPostRef = Api.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId ?? "")
            myPostRef.setValue(true, withCompletionBlock: {(error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            onSuccess() //MIGHT NEED SOMETHING HERE
        })
    }
    }
}

