//
//  SMViewController.swift
//  
//
//  Created by Jiayi Wu on 7/31/20.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class SMViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    private var collectionView: UICollectionView?
    @IBOutlet var table: UITableView!
    private let db = Database.database().reference()
    var models = [CreationPost]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        //fake data need be replaced
        
        fetchdata()
        
        
//        models.append(CreationPost(numberOfRecreate: 100, username: "Yuchen", userImageName:"yuch", postImage: UIImage(named: "post_1")!))
//
//        models.append(CreationPost(numberOfRecreate: 120, username: "Vishal", userImageName:"head_1", postImage: UIImage(named: "post_3")!))
//
//        models.append(CreationPost(numberOfRecreate: 50, username: "Jiayi", userImageName:"head_2", postImage: UIImage(named: "post_2")!))
//        print(models.count)
        
    }
    func fetchdata(){
        db.child("posting").observeSingleEvent(of: .value, with: {snapshot in guard let
            value = snapshot.value as? [String: Any] else {
                return
            }
            
            guard let urlString = value["ImageURL"]  as? String, let url = URL(string: urlString) else{
                return
            }
            
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data!)!
            let model = CreationPost(numberOfRecreate: 0, username: value["userID"] as! String, userImageName:"yuch", postImage: image, descriptiontext: value["Description"] as! String)
            self.models.append(model)
            print(self.models)
            self.table.reloadData()
            
            
        })
        
    }
   
    func numberOfSections (in tableView: UITableView) ->Int{
        return 1
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
}

struct CreationPost {
    let numberOfRecreate: Int
    let username: String
    let userImageName: String
    let postImage: UIImage
    let descriptiontext: String
    
}
