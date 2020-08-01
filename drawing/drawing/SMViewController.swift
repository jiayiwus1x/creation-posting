//
//  SMViewController.swift
//  
//
//  Created by Jiayi Wu on 7/31/20.
//

import UIKit

class SMViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    private var collectionView: UICollectionView?
    @IBOutlet var table: UITableView!
    
    var models = [CreationPost]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        //fake data need be replaced
        models.append(CreationPost(numberOfLikes: 200, username: "Yuchen", userImageName:"yuch", postImageName: "post_1"))
        
        models.append(CreationPost(numberOfLikes: 50, username: "Jiayi", userImageName:"head_2", postImageName: "post_2"))
 
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
    let numberOfLikes: Int
    let username: String
    let userImageName: String
    let postImageName: String
    
}
