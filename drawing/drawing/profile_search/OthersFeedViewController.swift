//
//  OthersFeedViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/24/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SDWebImage
import FirebaseDatabase

class OthersFeedViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate  {
    public var completionHandler: (() -> Void)?
    
    
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var Username: UILabel!
    private let db = Database.database().reference()
    @IBOutlet weak var my_feed: UITableView!
    @IBOutlet weak var creato: UIButton!
    var models = [CreationPost]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        my_feed.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        my_feed.delegate = self
        my_feed.dataSource = self
        
        let emailAddress = UserDefaults.standard.value(forKey:"feedemail") as? String ?? "No Name"
        
        let path =  DatabaseManager.GetImgPath(email: emailAddress)
        StorageManager.shared.downloadURL(for: path, completion: { result in
                   switch result {
                   case .success(let url):
                    self.profilepic.sd_setImage(with: url, completed: nil)
                   case .failure(let error):
                       print("Failed to get download url: \(error)")
                   }
        })
        // Do any additional setup after loading the view.
        fetchpostings(email: emailAddress)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220 + view.frame.size.width
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        
        cell.configure(with: models[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    func fetchpostings(email: String){
        let ref = db.child("postings").queryOrdered(byChild: "email").queryEqual(toValue: email)
        ref.observe(.childAdded, with: {
            (snapshot) in guard let
                value = snapshot.value as? [String: Any] else {
                    return
            }
            
            guard let urlString = value["ImageURL"]  as? String, let url = URL(string: urlString) else{
                return
            }
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data!)!
            
            let model = CreationPost(Id: value["ID"] as! String, numberOfRecreate: 0, username: value["userID"] as! String, email: value["email"] as! String, postImage: image, descriptiontext: value["Description"] as! String, timestamp: value["Time"] as! String)
            self.models.append(model)
            self.my_feed.reloadData()
            self.creato.setTitle("creato \(self.models.count)", for: .normal)
            self.Username.text = model.username
        })
        
    }
}
