//
//  listViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 7/20/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import RealmSwift

class SavedItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var project: Data = Data()
    let linecolor = List<String>()
    let linewidth = List<Float>()
    let lineop = List<Float>()
    let pos = List<String>()
    let ind = List<Int>()

    //@objc dynamic var lines: Data = Data()
    //@objc dynamic var lines: AnyClass = [TouchPointsAndColor]()
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var table: UITableView!
    @IBOutlet var label: UILabel!
    @IBOutlet var AddButton: UIBarButtonItem!
    
    @IBOutlet var PostButton: UIBarButtonItem!
    @IBOutlet var ProfileButton: UIBarButtonItem!
    // saving
    private var models = [SavedItem]()
    //private var drawings = [CanvasView]()
    lazy var realm:Realm = {
        return try! Realm()
    }()
    // private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileButton.image = UIImage(named: "head_1")
        setupNavigationController()
        table.register(ImageViewCell.self, forCellReuseIdentifier: "cell")
        
        table.delegate = self
        table.dataSource = self
        models = realm.objects(SavedItem.self).map({ $0 })
        
        title = "Projects"
        // Do any additional setup after loading the view.
    }
   private func setupNavigationController(){
//        let button = UIButton.init(type: .custom)
//        //set image for button
//        button.setImage(UIImage(named: "head_1"), for: .normal)
//        button.addTarget(self, action: #selector(didTapProfile), for: UIControl.Event.touchUpInside)
//        button.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
//        button.imageView?.contentMode = .scaleAspectFit
//        let ProfileButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItems = [AddButton, PostButton, ProfileButton]
    }
    
    @IBAction func didTapProfile() {
        guard let vc = storyboard?.instantiateViewController(identifier: "profile") as? ProfileViewController else {
            return
        }
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = "Jiayi"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func didTapPostButton() {
           print("in the didTapPost func")
           guard let vc = storyboard?.instantiateViewController(identifier: "share") as? NewViewController else {
               return
           }
           vc.completionHandler = { [weak self] in
               self?.refresh()
           }
           vc.title = "Sharing"
           vc.navigationItem.largeTitleDisplayMode = .never
           navigationController?.pushViewController(vc, animated: true)
       }
      
   
    func refresh() {
        models = realm.objects(SavedItem.self).map({ $0 })
        print("did refreshed,\n", SavedItem.self)
        table.reloadData()
    }
    
    // tables
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageViewCell
    
        cell.textLabel?.text = models[indexPath.row].title
        
        let imagedata = models[indexPath.row].project
        cell.mainImageView.image = UIImage(data: imagedata)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = models[indexPath.row]
        // Show note controller
        guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else {
            return
        }
        vc.item = model
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = model.title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imagedata = models[indexPath.row].project
        let currentImage =  UIImage(data: imagedata)
        guard let imageRatio = currentImage?.getImageRatio() else { return 50 }
        return tableView.frame.width / imageRatio
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            try! realm.write{ realm.delete(models[indexPath.row])}
            models.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
        }
    }
}

