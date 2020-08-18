//
//  ShareViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/11/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import RealmSwift

class ShareViewController: UIViewController {
    @IBOutlet var sharingImage: UIImageView!
    @IBOutlet var PostButton: UIButton!
    @IBOutlet var textfield: UITextView!
    
    private var models = [SavedItem]()
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        models = realm.objects(SavedItem.self).map({ $0 })
        sharingImage.image = UIImage(data: models.last!.project)
        // Do any additional setup after loading the view.
    }
    @IBAction func didTapShare(){
        
    }
}
