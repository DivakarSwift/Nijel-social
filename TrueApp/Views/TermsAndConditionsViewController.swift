//
//  TermsAndConditionsViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 12/7/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var termsWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://termsfeed.com/terms-conditions/faf23cd7494e7eccca3c27770ee492c3")
        termsWebView.loadRequest(URLRequest(url:url!))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
