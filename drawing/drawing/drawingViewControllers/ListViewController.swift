//
//  listViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 7/20/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var table: UITableView!
    @IBOutlet var label: UILabel!
    @IBOutlet var AddButton: UIBarButtonItem!
    
    @IBOutlet weak var RefreshButton: UIBarButtonItem!
    @IBOutlet var ProfileButton: UIBarButtonItem!
    // saving
    private var models = [Project]()
    //Database.database().isPersistenceEnabled = true
    private let db = Database.database().reference()
    var safeEmail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.keepSynced(true)
        //ProfileButton.image = UIImage(named: "head_1")
        setupNavigationController()
        table.register(ListViewCell.nib(), forCellReuseIdentifier: ListViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        //models = realm.objects(Project.self).map({ $0 })
        let user = Auth.auth().currentUser
        safeEmail = DatabaseManager.safeEmail(emailAddress: user?.email ?? "No_email")
        fetchprojects(safe_email: safeEmail)
        
        title = "Projects"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            //let vc = ViewController()
            let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginNav")
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }
        
    }
    
    func fetchprojects(safe_email: String){
        print("fetching", safe_email + "-projects")
       
        db.child(safe_email + "-projects").queryOrdered(byChild: "order").observe(.childAdded, with: {
            (snapshot) in guard let
                value = snapshot.value as? [String: Any] else {
                    print("value not exists")
                    return
            }
            
            guard let urlString = value["imageurl"]  as? String, let url = URL(string: urlString) else{
                print("image url not exist")
                return
            }
            
            let data = try? Data(contentsOf: url)
            let id = value["ID"] ?? UUID().uuidString
            print(id)
            let model = Project(Id: id as! String, Image: data!, linecolor: value["linecolor"] as! [String], lineop: value["lineop"] as! [Float], linewidth: value["linewidth"] as! [Float], pos: value["pos"] as! [String], ind: value["ind"] as! [Int], imageurl: value["imageurl"] as! String)
         
            self.models.append(model)
            DispatchQueue.main.async {
                self.table.reloadData()
                
            }
        })
        
    }
    private func setupNavigationController(){
        
        navigationItem.rightBarButtonItems = [AddButton, ProfileButton, RefreshButton]
    }
    
    @IBAction func didTapProfile() {
        guard let vc = storyboard?.instantiateViewController(identifier: "profile") as? ProfileViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func refreshbutton(_ sender: Any) {
        self.models = [Project]()
        fetchprojects(safe_email: safeEmail)
        
    }
    @IBAction func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "enter") as? NewViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = "New Project"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func refresh() {
        self.models = [Project]()
        fetchprojects(safe_email: safeEmail)
        table.reloadData()
    }
    
    //mark: tables
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.identifier, for: indexPath) as! ListViewCell
        cell.configure(with: models[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = models[indexPath.row]
        guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else {
            return
        }
        vc.item = model
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            //implement deleting in firebase
            
            let name = safeEmail + "-projects"
            let id = models[indexPath.row].Id
            
            
            db.child(name).observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: Any]]{
                    for (i,arr) in usersCollection.enumerated(){
                        if arr["ID"] as? String == id{
                            usersCollection.remove(at: i)
                            print("reomoved one entry, ", i)
                            break
                        }
                    }
                    
                    self.db.child(name).setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            return
                        }
                    })
                }
            })
            models.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
        }
    }
}

extension ListViewController: ListViewCellDelegate{
    
    func didTapShare(with item: Project) {
        if item.Image.isEmpty {
            print("something went wrong")
        }
        else{
            UserDefaults.standard.set(item.Image, forKey: "share_item")
            UserDefaults.standard.set(item.Id, forKey: "share_id")
            guard let vc = storyboard?.instantiateViewController(identifier: "share") as? ShareViewController else {
                return
            }
            vc.completionHandler = { [weak self] in
                self?.refresh()
            }
            vc.title = "Sharing"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}
