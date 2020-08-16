//
//  ProfileViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 8/14/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    public var completionHandler: (() -> Void)?
    @IBOutlet weak var profilepic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
