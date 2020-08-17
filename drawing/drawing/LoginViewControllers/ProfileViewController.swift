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
        
        dismiss(animated: true, completion: nil)
    }
    

}
