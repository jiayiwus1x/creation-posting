//
//  SearchViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/21/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import JGProgressHUD
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filtereddata.isEmpty{
            return filtereddata.count
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if !filtereddata.isEmpty{
            cell.textLabel?.text = filtereddata[indexPath.row]
        }
        else{cell.textLabel?.text = data[indexPath.row]}
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var field: UITextField!
    var data = [String]()
    var filtereddata = [String]()

    private var hasFetched = false
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        
        setupData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            filterText(text + string)
        
        }
        
        return true
    }
    func setupData(){
        
        DatabaseManager.shared.getAllUsers(completion: {[weak self] result in
            switch result {
            case .success(let usersCollection):
                
                for user in usersCollection{
                    self?.data.append(user["name"]!)
                    
                }
                self?.table.reloadData()
            case .failure(let error):
                print("Failed to get usres: \(error)")
            }
        })
    }
    
    func filterText(_ query: String){
        filtereddata.removeAll()
     
        for string in data {
            if string.lowercased().starts(with: query.lowercased()){
                filtereddata.append(string)
            }
        }
        table.reloadData()
    }
}
