//
//  ViewController.swift
//  RBiometric
//
//  Created by Raj Sharma on 28/11/19.
//  Copyright © 2019 Raj Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTouchAuth(_ sender: Any) {
        
        RBiometric.show()
        RBiometric.shared.onAuthSuccess = { [weak self] in
            self?.statusLabel.textColor = UIColor.green
            self?.statusLabel.text = "Success\nAuthenticated successfully"
        }
        
        RBiometric.shared.onAuthError = { [weak self] (error) in
            self?.statusLabel.textColor = UIColor.red
            self?.statusLabel.text = "Error\n" + error.message
           if error == .userCancel {
              RBiometric.dismissBiometric()
           }
        }
    }
}
