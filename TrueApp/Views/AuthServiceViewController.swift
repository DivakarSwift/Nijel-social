//
//  AuthServiceViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 8/31/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


class AuthServiceViewController: UIViewController {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        print("sign in")
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        if error != nil{
            onError(error!.localizedDescription)
            return
        }
        onSuccess()
        }
}
    
    

//    static func signUp(fullName: String, phonenumber: String, username: String, email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
//        print("sign in")
//        Auth.auth().createUser(withEmail: email, password: password) { (user: AuthDataResult?, error: Error?) in
//            if error != nil {
//                print(error!.localizedDescription)
//                return
//            }
//            guard let user = user?.user else { return } //user? might be AuthDataResult? //might not be in right spot
//            let ref = Database.database().reference()
//            let usersReference = ref.child("users")
//            let uid = Auth.auth().currentUser!.uid
//            let newUserReference = usersReference.child(uid)
//            newUserReference.setValue(["fullName": self.FullNameTextField.text!, "phoneNumber": self.PhoneNumberTextField.text!, "username": self.usernameTextField.text!, "email": self.EmailTextField.text!])
//            print("description: \(newUserReference.description())")
//        }
//        }
    
    
    static func setUserInformation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void ){
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl]) //ADD FULLNAME AND PHONENUMBER
        onSuccess()
        
    }
    static func updateUserInfo(username: String, email: String, imageData: Data, phoneNumber: String, fullName: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){ //ADD PHONE# AND FULL NAME
        Auth.auth().currentUser!.updateEmail(to: email, completion: {(error) in //ERROR
            if error != nil {
                onError(error!.localizedDescription)
            } else{
                let uid = Auth.auth().currentUser!.uid
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid)
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
//                    <#code#>
//                })
//                put(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    //let profileImageUrl = metadata?.downloadURL()?.absoluteString
                   // self.updateDatabase(profileImageUrl: profileImageUrl!, username: username, email: email, phoneNumber:phoneNumber, fullName:fullName, onSuccess: onSuccess, onError: onError)
                })
            }
        })
        
    }
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, fullName: String, phoneNumber: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageUrl": profileImageUrl, "phoneNumber" : phoneNumber, "fullName" : fullName] //ADD FULLNAME AND PHONENUMBER
        Api.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error!.localizedDescription)
            } else{
                onSuccess()
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                onSuccess()
            } catch let logoutError as NSError {
                onError(logoutError.localizedDescription)
            }
        }
        
    }
    }





