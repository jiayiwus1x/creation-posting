//
//  PostTableViewCell.swift
//  drawing
//
//  Created by Jiayi Wu on 7/31/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol PostTableViewCellDelegate: AnyObject {
    func didTapButton (with title: String)
    func didTapProfile(with item: String)
    func didTapCollab(with postingModel: CreationPost)
    func didTapVideo(with postingModel: CreationPost)

}
class PostTableViewCell: UITableViewCell {
    
    weak var delegate: PostTableViewCellDelegate?
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var collButton: UIButton!
    @IBOutlet var descriptiontext: UITextView!
    @IBOutlet weak var timestamp: UILabel!
    
    var model: CreationPost!
    static let identifier = "PostTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapProfile)))
    }

    @IBAction func didTapVideo(_ sender: Any) {
        delegate?.didTapVideo(with: self.model)
    }
    @IBAction func didTapColla(_ sender: Any) {
        delegate?.didTapCollab(with: self.model)
    }
    @IBAction func didTapButton(_ sender: Any) {
        delegate?.didTapButton(with: "it works!")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: CreationPost){
        self.likesLabel.text = "\(model.numberOfRecreate) ReCreate"
        self.usernameLabel.text = model.username
        self.postImageView.image = model.postImage
        self.descriptiontext.text = model.descriptiontext

        self.timestamp.text = model.timestamp
        let path = model.profilePictureUrl
        StorageManager.shared.downloadURL(for: path, completion: { result in
                   switch result {
                   case .success(let url):
                    self.userImageView.sd_setImage(with: url, completed: nil)
                   case .failure(let error):
                       print("Failed to get download url: \(error)")
                   }
        })
        self.model = model
        let user = Auth.auth().currentUser
        if (model.Id == "None" || model.email == user?.email) {
            collButton?.isHidden = true
        }
        else{
            collButton?.isHidden = false
        }
    }
    @objc func didTapProfile(){
        delegate?.didTapProfile(with: self.model.email)
       }
    
}
