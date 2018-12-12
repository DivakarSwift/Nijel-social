//
//  PreviewViewController.swift
//  TrueApp
//
//  Created by Nijel Hunt on 9/11/18.
//  Copyright © 2018 Nijel Hunt. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
        // Do any additional setup after loading the view.
    }

    @IBAction func cancelButton_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }
    
}
