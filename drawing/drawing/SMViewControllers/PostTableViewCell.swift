//
//  PostTableViewCell.swift
//  drawing
//
//  Created by Jiayi Wu on 7/31/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var collButton: UIButton!
    @IBOutlet var descriptiontext: UITextView!
    @IBOutlet weak var timestamp: UILabel!
    
    static let identifier = "PostTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    }
}
