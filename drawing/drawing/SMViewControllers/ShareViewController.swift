//
//  ShareViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/11/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth


class ShareViewController: UIViewController {
    public var completionHandler: (() -> Void)?
    
    @IBOutlet var sharingImage: UIImageView!
    @IBOutlet var PostButton: UIButton!
    @IBOutlet var textfield: UITextView!
    var model: Project!
    private let storage = Storage.storage().reference()
    private let db = Database.database().reference()
    var coll_flag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let filename = safeEmail + "_post_pic" + self.model.Id
        
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
                                            self.addProjShare(ImageURL: urlString)
                                            
                                        })
                                        
        })
        let smViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.smViewController ) as! SMViewController
        
        self.navigationController?.pushViewController(smViewController, animated: true)
        
    }
    
    @objc private func addposting(urlString: String, text: String){
        let (now, timestring) = DatabaseManager.get_Date()
        let order = 0 - Int(now.timeIntervalSince1970)
        
        let email = UserDefaults.standard.value(forKey:"email") as? String ?? "No email"
        let id = UserDefaults.standard.value(forKey:"share_id") as? String
        let object: [String: Any] = [
            "ID": id ?? "No share id",
            "email": email,
            "userID": UserDefaults.standard.value(forKey:"name") as? String ?? "No Name",
            "ImageURL": urlString,
            "Description": text,
            "Time": timestring,
            "numberOfRecreate": 0,
            "order": order
            
        ]
        DatabaseManager.shared.addCollection(obj: object, collectionName: "postings")
        
    }
    @objc func addProjShare(ImageURL: String){
        if self.model != nil {
            let email = UserDefaults.standard.value(forKey:"email") as? String ?? "No email"
            let (now, timestring) = DatabaseManager.get_Date()
            let order = 0 - Int(now.timeIntervalSince1970)
            let obj: [String: Any] = [
                "ID": self.model.Id,
                "last modified": timestring,
                "linecolor": self.model.linecolor,
                "lineop": self.model.lineop,
                "linewidth": self.model.linewidth,
                "pos": self.model.pos,
                "ind": self.model.ind,
                "imageurl": ImageURL,
                "order": order,
                "emailList": [email],
                "IDList": [self.model.Id],
                "placeholder":[self.model.ind.count]
                
            ]
            DatabaseManager.shared.addCollection(obj: obj, collectionName: "SharedProjects")
        }
        
    }
}

