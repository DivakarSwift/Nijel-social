//
//  String.swift
//  TrueApp
//
//  Created by Evgeny on 10/12/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}


func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension NSAttributedString {
    func archineWithUsersIds() -> String {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: self)
        return data.base64EncodedString()
    }
}

extension String {
    private func getUserID() -> String {
        return Auth.auth().currentUser?.uid ?? UserID.undefined.rawValue
    }
    
    func unarchiveWithUserIds() -> NSAttributedString {
        guard let data = Data(base64Encoded: self), let attributedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString else  {
            let url = URL(string: "\(getUserID())")
            return NSAttributedString(string: self, attributes: [.link: url!])
        }
        return attributedString
    }
    
    func getUserAttributes() -> [NSAttributedString.Key: Any] {
        let url = URL(string: "\(getUserID())")
        return  [.link: url!, .foregroundColor: UIColor.black]
    }
    
    func addSelfUserAttributes() -> NSAttributedString {
        let url = URL(string: "\(getUserID())")
        return NSAttributedString(string: self, attributes: [.link: url!])
    }
    
    enum UserID: String {
        case undefined
    }
}

extension NSAttributedString.Key {
    static var userID = NSAttributedString.Key("userID")
}
