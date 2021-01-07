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
import FirebaseAuth

class SMViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    private var collectionView: UICollectionView?
    @IBOutlet var table: UITableView!
    private let db = Database.database().reference()
    var models = [CreationPost]()
    var refreshControl = UIRefreshControl()
    var obj : [String: Any]!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        table.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        //fetching data
        
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
      
            let Id = value["ID"] ?? "None"
            let model = CreationPost(Id: Id as! String, numberOfRecreate: value["numberOfRecreate"] as! Int, username: value["userID"] as! String, email: value["email"] as! String, postImage: image, descriptiontext: value["Description"] as! String, timestamp: value["Time"] as! String)
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
        cell.selectionStyle = .none
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//
//    }
//
    
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
    
    func didTapVideo(with postingModel: CreationPost){
        //if email is in the collebrate list, clone the project into my project page
        if postingModel.Id == "None"{
            print("not supporting collabration")
        }
        else{
            print("collabrate on this!")
            
            DatabaseManager.shared.getAProject(postingModel: postingModel, completion: {
                [weak self] result in
                switch result {
                case .success(let obj):
                    guard let vc = self?.storyboard?.instantiateViewController(identifier: "videoVC") as? VideoViewController else {
                        return
                    }
                    vc.title = "Animation"
                    vc.obj = obj
                    vc.navigationItem.largeTitleDisplayMode = .never
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                case .failure(let error):
                    print("\(error)")
                }
            })
        }
    }
        
        
    func didTapCollab(with postingModel: CreationPost){
        //if email is in the collebrate list, clone the project into my project page
        if postingModel.Id == "None"{
            print("not supporting collabration")
        }
        else{
            print("collabrate on this!")
            
            DatabaseManager.shared.getAProject(postingModel: postingModel, completion: {
                [weak self] result in
                switch result {
                case .success(let obj):
                    
                    self?.clonePorject(object: obj)
                    self?.switchController(identifierName: "listVC")
                case .failure(let error):
                    print("\(error)")
                }
            })
        }
        
    }
    func clonePorject(object: [String: Any]){
        self.obj = object
        self.obj["ID"] = UUID().uuidString
        let user = Auth.auth().currentUser
        let safeEmail = DatabaseManager.safeEmail(emailAddress: user?.email ?? "No_email")
        let name = safeEmail + "-projects"
        DatabaseManager.shared.addCollection(obj: self.obj, collectionName: name)
    }
    
    
    func switchController(identifierName: String){
        print(identifierName)
        if identifierName == "OthersFeed"{
            guard let vc = self.storyboard?.instantiateViewController(identifier: identifierName) as? OthersFeedViewController else {
                return
            }
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        }
        if identifierName == "listVC"{
            print("hello")
            guard let vc = self.storyboard?.instantiateViewController(identifier: identifierName) as? ListViewController else {
                return
            }
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
    }
    
}
