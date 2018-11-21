//
//  UIView+Nib.swift
//  TrueApp
//
//  Created by Sorochinskiy Dmitriy on 22.11.2018.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    class func fromNib<T: UIView>(name: String) -> T {
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)![0] as! T
}
}
