//
//  FriendsViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/24/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let database = Database.database().reference()
    var friendslist = [String]()
    @IBOutlet weak var friendtable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        
        friendtable.delegate = self
        friendtable.dataSource = self
        fetchfriends(email: user?.email ?? "no email")
        friendtable.reloadData()
    }
    
    //mark: tables
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendslist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = friendslist[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.identifier, for: indexPath) as! ListViewCell
//        cell.configure(with: models[indexPath.row])
//        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    func fetchfriends(email: String){
        let safe_email = DatabaseManager.safeEmail(emailAddress: email)
        self.database.child(safe_email).observeSingleEvent(of: .value){
            snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                
                print("something went wrong check value below \n \(snapshot.value ?? "found nothing")")
                return
                
            }
            self.friendslist = (value["following"] as? [String])!
            print(self.friendslist)
            self.friendtable.reloadData()
            }
    }

}
