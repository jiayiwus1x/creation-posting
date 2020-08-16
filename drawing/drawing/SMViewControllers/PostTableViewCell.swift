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
        self.userImageView.image =  UIImage(named: model.userImageName)
        self.postImageView.image = model.postImage
        self.descriptiontext.text = model.descriptiontext
    }
}
