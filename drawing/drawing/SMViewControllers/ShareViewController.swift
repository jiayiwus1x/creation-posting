//
//  ShareViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/11/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseStorage
import FirebaseDatabase

class ShareViewController: UIViewController {
    public var completionHandler: (() -> Void)?
    
    @IBOutlet var sharingImage: UIImageView!
    @IBOutlet var PostButton: UIButton!
    @IBOutlet var textfield: UITextView!
    
    private let storage = Storage.storage().reference()
    private let db = Database.database().reference()
    
    
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
        guard let imageData = sharingImage.image?.pngData() else {
            return
        }
        let textdata = textfield.text!
        
        storage.child("images/file.png").putData(imageData,
                                                 metadata: nil,
                                                 completion: { _, error in
                                                    guard error == nil else {
                                                        print("Failed to Upload")
                                                        return
                                                    }
                                                    self.storage.child("images/file.png").downloadURL(completion: {url, erro in guard let url = url, error == nil else{
                                                        return
                                                        }
                                                        
                                                        let urlString = url.absoluteString
                                                        self.addposting(urlString: urlString, text: textdata)
                                                        
                                                        })
                                    
        })
        let smViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.smViewController ) as! SMViewController
        self.navigationController?.pushViewController(smViewController, animated: true)
        
    }
    
    @objc private func addposting(urlString: String, text: String){
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        
        let object: [String: Any] = [
            "email": UserDefaults.standard.value(forKey:"email") as? String ?? "No email",
            "userID": UserDefaults.standard.value(forKey:"name") as? String ?? "No Name",
            "ImageURL": urlString,
            
            "Description": text,
            "Time": formatter.string(from: now),
            "numberOfRecreate": 0
            
        ]
        
        db.child("posting").setValue(object)
    }
}

