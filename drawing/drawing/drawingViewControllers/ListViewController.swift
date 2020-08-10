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
    // saving
    private var models = [SavedItem]()
    //private var drawings = [CanvasView]()
    lazy var realm:Realm = {
        return try! Realm()
    }()
    // private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(ImageViewCell.self, forCellReuseIdentifier: "cell")
        
        table.delegate = self
        table.dataSource = self
        models = realm.objects(SavedItem.self).map({ $0 })
        
        title = "Projects"
        // Do any additional setup after loading the view.
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

