//
//  ViewControllerInstantiateProtocol.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 9/26/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation
import UIKit

class StoryboardControllerProvider<T: UIViewController> {
    
    class func controller(from storyboard: UIStoryboard, identifier: String? = nil) -> T? {
        var controllerId: String = ""
        if identifier != nil {
            controllerId = identifier!
        } else {
            let nameSpaceClassName = NSStringFromClass(T.classForCoder())
            controllerId = nameSpaceClassName.components(separatedBy: ".").last!
        }
        
        return storyboard.instantiateViewController(withIdentifier: controllerId) as? T
    }
    
    class func controller(storyboardName: String, identifier: String? = nil) -> T? {
        let storyboard = UIStoryboard(name: storyboardName,
                                      bundle: nil)
        return controller(from: storyboard, identifier: identifier)
    }
    
}
