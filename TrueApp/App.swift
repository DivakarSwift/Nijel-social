//
//  App.swift
//  TrueApp
//
//  Created by Nikita Kazakov on 10/3/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import Foundation

class App{
    static let shared = App()
    var currentUser: User!
    private init() {
    }
}
