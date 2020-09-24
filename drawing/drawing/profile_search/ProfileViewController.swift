//
//  ProfileViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/14/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SDWebImage
import FirebaseDatabase

class ProfileViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate  {
    public var completionHandler: (() -> Void)?
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var Username: UILabel!
    private let db = Database.database().reference()
    @IBOutlet weak var my_feed: UITableView!
    @IBOutlet weak var creato: UIButton!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var logout: UIButton!
    var models = [CreationPost]()
    override func viewDidLoad() {
        title = "My profile"
        super.viewDidLoad()
        my_feed.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        my_feed.delegate = self
        my_feed.dataSource = self
        
        let user = Auth.auth().currentUser
        
        email.text = user?.email
        Username.text = UserDefaults.standard.value(forKey:"name") as? String ?? "No Name"
        
        let path = GetImgPath()
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                self.profilepic.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        // Do any additional setup after loading the view.
        fetchpostings(email: user?.email ?? "no email")
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let selectedImage = info[.originalImage] as? UIImage
        else {
            fatalError("Expected a dictionary containing an image, \(info)")
        }
        profilepic.image = selectedImage
        ChangeProfilepic(fileName: GetImgPath(), data: selectedImage.pngData()!)
        dismiss(animated: true, completion: nil)
    }
    
    func ChangeProfilepic(fileName: String, data: Data){
        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
            switch result {
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                print(downloadUrl)
            case .failure(let error):
                print("Storage maanger error: \(error)")
            }
        })
    }
    
    func GetImgPath() -> String{
        let user = Auth.auth().currentUser
        let safeEmail = DatabaseManager.safeEmail(emailAddress: user?.email ?? "No_email")
        let filename = safeEmail + "_profile_pic"
        let path = "images/profileImg/"+filename
        return path
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
    func fetchpostings(email: String){
        let ref = db.child("postings").queryOrdered(byChild: "email").queryEqual(toValue: email)
        ref.observe(.childAdded, with: {
            (snapshot) in guard let
                                    value = snapshot.value as? [String: Any] else {
                return
            }
        
        guard let urlString = value["ImageURL"]  as? String, let url = URL(string: urlString) else{
            return
        }
        let data = try? Data(contentsOf: url)
        guard let image = UIImage(data: (data)!) else{
            return
        }
        
        let model = CreationPost(Id: value["ID"] as! String, numberOfRecreate: 0, username: value["userID"] as! String, email: value["email"] as! String, postImage: image, descriptiontext: value["Description"] as! String, timestamp: value["Time"] as! String)
        self.models.append(model)
        self.my_feed.reloadData()
        self.creato.setTitle("creato \(self.models.count)", for: .normal)
        })
        
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Log Out",                                         message: "Are you sure you want to log out?",                               preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(
                                title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            AuthManager.shared.logOut(completion: {success in
                DispatchQueue.main.async {
                    if success{
                        let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginNav")
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                        
                    }
                    else{
                        fatalError("could not log out user")
                    }
                }
            })
            
        }))
        actionSheet.popoverPresentationController?.sourceView = my_feed
        actionSheet.popoverPresentationController?.sourceRect = my_feed.bounds
        present(actionSheet, animated: true)
    }
}

