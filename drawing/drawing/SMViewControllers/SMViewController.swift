//
//  SMViewController.swift
//  
//
//  Created by Jiayi Wu on 7/31/20.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class SMViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    private var collectionView: UICollectionView?
    @IBOutlet var table: UITableView!
    private let db = Database.database().reference()
    var models = [CreationPost]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        //fake data need be replaced
        
        fetchpostings()
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.addSubview(refreshControl)
        
    }
    @objc func refresh(_ sender: AnyObject) {
        self.models = [CreationPost]()
        fetchpostings()
        table.reloadData()
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
      
    }
    
    func fetchpostings(){
        db.child("postings").queryOrdered(byChild: "order").observe(.childAdded, with: {
            (snapshot) in guard let
                value = snapshot.value as? [String: Any] else {
                    return
            }
            
            guard let urlString = value["ImageURL"]  as? String, let url = URL(string: urlString) else{
                return
            }
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data!)!
            
            let model = CreationPost(numberOfRecreate: 0, username: value["userID"] as! String, email: value["email"] as! String, postImage: image, descriptiontext: value["Description"] as! String, timestamp: value["Time"] as! String)
            self.models.append(model)
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
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
}

extension SMViewController: PostTableViewCellDelegate{
    func didTapProfile(with item: String) {
        
        print("tap registered with email", item)
        guard let vc = storyboard?.instantiateViewController(identifier: "OthersFeed") as? OthersFeedViewController else {
            return
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        UserDefaults.standard.setValue(item, forKey: "feedemail")
        
    }
    
    func didTapButton(with title: String) {
        print("\(title)")
    }
    func didTapCollab(with email: String){
        //if email is in the collebrate list, clone the project into my project page
        
    }
}
