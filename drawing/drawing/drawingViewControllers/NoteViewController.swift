//
//  NoteViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 7/20/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class NoteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public var item: Project?
    public var deletionHandler: (() -> Void)?
    private let db = Database.database().reference()
    @IBOutlet var project: UIImage!
    
    private let storage = Storage.storage().reference()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var canvasView: CanvasView!
    public var completionHandler: (() -> Void)?
    
    @IBOutlet weak var featureView: UIView!
    @IBOutlet weak var arrowup: UIButton!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var opacitySlider: UISlider!
    var animationTime = 0.35
    var kHeight: CGFloat = 130
    var colorsArray: [UIColor] = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 1, green: 0.4059419876, blue: 0.2455089305, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 1, green: 0.4059419876, blue: 0.2455089305, alpha: 1), #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3823936913, green: 0.8900789089, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.4528176247, blue: 0.4432695911, alpha: 1), #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        if let imageData = item?.Image, !imageData.isEmpty{
            project = UIImage(data: imageData)
            
            var lines = [TouchPointsAndColor]()
            
            var firstind = Int(0)
            var secondind = Int(0)
            for (i, _) in (item?.linewidth.enumerated())! {
                var points = Array<CGPoint>()
                if i > 0{
                    firstind += item?.ind[i-1] ?? 0
                }
                secondind = firstind + (item?.ind[i])!
                for j in Range(uncheckedBounds: (firstind , secondind)){
                    points.append(NSCoder.cgPoint(for: (item?.pos[j])!))
                }
                
                var line = TouchPointsAndColor(color: UIColor.color(withCodedString: (item?.linecolor[i])!)!, points: points)
                
                line.width = CGFloat((item?.linewidth[i])!)
                line.opacity = CGFloat((item?.lineop[i])!)
                lines.append(line)
            }
            canvasView.lines = lines
            
        }
        
        opacitySlider.tintColor = .red
        featureView.transform = CGAffineTransform(translationX: 0, y: kHeight - (kHeight - 80))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveButton))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickHideShowFeatureView(_ sender: UIButton) {
        if sender.isSelected {
            UIView.animate(withDuration: animationTime) {
                sender.isSelected = false
                self.arrowup.setBackgroundImage(#imageLiteral(resourceName: "up-arrow"), for: .normal)
                self.featureView.transform = CGAffineTransform(translationX: 0, y: self.kHeight - (self.kHeight - 80))
            }
        } else {
            UIView.animate(withDuration: animationTime) {
                sender.isSelected = true
                self.arrowup.setBackgroundImage(#imageLiteral(resourceName: "down-arrow"), for: .normal)
                self.featureView.transform = CGAffineTransform.identity
            }
        }
        
    }
    @IBAction func onClickBrushWidth(_ sender: UISlider) {
        canvasView.strokeWidth = CGFloat(sender.value)
    }
    @IBAction func onClickOpacity(_ sender: UISlider) {
        canvasView.strokeOpacity = CGFloat(sender.value)
    }
    @IBAction func onClickClear(_ sender: Any) {
        canvasView.clearCanvasView()
    }
    @IBAction func onClickUndo(_ sender: Any) {
        canvasView.undoDraw()
    }
    @IBAction func onClickSave(_ sender: Any) {
        let image = canvasView.takeScreenshot()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextType:)), nil)
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextType: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func didTapSaveButton() {
        if let project = canvasView.takeScreenshot().pngData(), !project.isEmpty {
            print("saving")
            
            var linecolor = [String]()
            var linewidth = [Float]()
            var lineop = [Float]()
            var pos = [String]()
            var ind = [Int]()
            for line in canvasView.lines {
                linecolor.append(line.color!.codedString!)
                linewidth.append(Float(line.width!))
                lineop.append(Float(line.opacity!))
                for (_, position) in (line.points?.enumerated())! {
                    pos.append(NSCoder.string(for: position))
                    
                }
                ind.append(line.points!.count)
            }
            let user = Auth.auth().currentUser
            let safeEmail = DatabaseManager.safeEmail(emailAddress: user?.email ?? "No_email")
            
            let path = self.item!.imageurl
            
            storage.child(path).putData(project,
                                        metadata: nil,
                                        completion: { _, error in
                                            guard error == nil else {
                                                print("Failed to Upload")
                                                return
                                            }
                                            self.storage.child(path).downloadURL(completion: {url, erro in guard let url = url, error == nil else{
                                                return
                                                }
                                                
                                                let urlString = url.absoluteString
                                            self.editproject(Imageurl: urlString, linecolor: linecolor, lineop: lineop, linewidth: linewidth, pos: pos, ind: ind, safeEmail: safeEmail)
                                                
                                            })
                                            
            })
            completionHandler?()
            let listViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.listViewController ) as! ListViewController
            
            self.navigationController?.pushViewController(listViewController, animated: true)}
            //navigationController?.popToRootViewController(animated: true)}
        else {
            print("Add something")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let view = cell.viewWithTag(111) {
            view.layer.cornerRadius = 3
            view.backgroundColor = colorsArray[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colorsArray[indexPath.row]
        canvasView.strokeColor = color
    }
    @objc private func editproject(Imageurl: String, linecolor: [String], lineop: [Float], linewidth: [Float], pos: [String], ind: [Int], safeEmail: String){
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let name = safeEmail + "-projects"
        let order = 0 - Int(now.timeIntervalSince1970)
       
        let obj: [String: Any] = [
            "ID" : self.item!.Id,
            "last modified": formatter.string(from: now),
            "linecolor": linecolor,
            "lineop": lineop,
            "linewidth": linewidth,
            "pos": pos,
            "ind": ind,
            "imageurl": Imageurl,
            "order": order,
            "emailList": self.item!.userList,
            "IDList": self.item!.IdList,
            "holderindex":self.item!.holderindex
        ]
        //db.child("latest_obj").setValue(obj)
        db.child(name).observeSingleEvent(of: .value, with: { snapshot in
            if var usersCollection = snapshot.value as? [[String: Any]]{
                for (i,arr) in usersCollection.enumerated(){
                    if arr["ID"] as? String == self.item!.Id{
                        usersCollection.remove(at: i)
                        print("reomoved one entry, ", i)
                        break
                    }
                }
                usersCollection.append(obj)
                self.db.child(name).setValue(usersCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        return
                    }
                })
            }
            else{ print("something went wrong")
             
            }
        })
    }
    
}
