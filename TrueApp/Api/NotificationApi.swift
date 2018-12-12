//
//  NotificationApi.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/12/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import FirebaseDatabase
class NotificationApi {
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id: String, completion: @escaping (NotificationApi) -> Void){
        REF_NOTIFICATION.child(id).queryOrdered(byChild: "timestamp").observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                print(dict)
                _ = Notification.transform(dict: dict, key: snapshot.key)
//                completion(newNoti)
            }
        })
    }
    
}
