//
//  PrivacyPolicyViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 12/7/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    @IBOutlet weak var privacyWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://privacypolicies.com/privacy/view/91355dcc8ea9a848914259215ca31aef")
        privacyWebView.loadRequest(URLRequest(url:url!))    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
