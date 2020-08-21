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

class ProfileViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    public var completionHandler: (() -> Void)?
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var Username: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    private func validateAuth(){
        
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

}
