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
import FirebaseAuth


class ShareViewController: UIViewController {
    public var completionHandler: (() -> Void)?
    
    @IBOutlet var sharingImage: UIImageView!
    @IBOutlet var PostButton: UIButton!
    @IBOutlet var textfield: UITextView!
    
    private let storage = Storage.storage().reference()
    private let db = Database.database().reference()
    
    
    private var models = [Project]()
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //models = realm.objects(Project.self).map({ $0 })
        let data = UserDefaults.standard.value(forKey:"share_item") as? Data
        
        sharingImage.image = UIImage(data: data!)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapShare(){
        guard let imageData = sharingImage.image?.pngData() else {
            return
        }
        let textdata = textfield.text!
        let user = Auth.auth().currentUser
        let safeEmail = DatabaseManager.safeEmail(emailAddress: user?.email ?? "No_email")
        let filename = safeEmail + "_post_pic" + String(Int.random(in: 0..<10000))

        let path = "images/post_images/"+filename
        
        storage.child(path).putData(imageData,
                                                 metadata: nil,
                                                 completion: { _, error in
                                                    guard error == nil else {
                                                        print("Failed to Upload")
                                                        return
                                                    }
                                                    self.storage.child(path).downloadURL(completion: {url, erro in guard let url = url, error == nil else{
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
        let order = 0 - Int(now.timeIntervalSince1970)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let id = UserDefaults.standard.value(forKey:"share_id") as? String
        let object: [String: Any] = [
            "ID": id ?? "No share id",
            "email": UserDefaults.standard.value(forKey:"email") as? String ?? "No email",
            "userID": UserDefaults.standard.value(forKey:"name") as? String ?? "No Name",
            "ImageURL": urlString,
            "Description": text,
            "Time": formatter.string(from: now),
            "numberOfRecreate": 0,
            "order": order,
            
            
        ]

        db.child("postings").observeSingleEvent(of: .value, with: { snapshot in
            if var usersCollection = snapshot.value as? [[String: Any]]{
                
                usersCollection.append(object)
                self.db.child("postings").setValue(usersCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        return
                    }
                })
            }
            else{
                print("database not exists!")
                let newCollection: [[String: Any]] = [
                    object] as [[String : Any]]
                
                self.db.child("postings").setValue(newCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        return
                    }
                })
            }
        })
    }
}

