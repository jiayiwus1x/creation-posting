//
//  ViewController.swift
//  firebase-app-tutorial
//
//  Created by Vishal Soni on 8/2/20.
//  Copyright © 2020 Vishal Soni. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Creation Sharing"
        setUpElements()
    }

    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    

}

