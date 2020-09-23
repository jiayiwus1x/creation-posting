//
//  ListViewCell.swift
//  drawing
//
//  Created by Jiayi Wu on 8/19/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
import SDWebImage

protocol ListViewCellDelegate: AnyObject {
    func didTapShare (with item: Project)
}

class ListViewCell: UITableViewCell {
    static let identifier = "ListViewCell"
    weak var delegate: ListViewCellDelegate?
    var model: Project!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var addcollebrators: UIButton!
    
    @IBOutlet weak var coll_label: UILabel!
    @IBOutlet weak var collab_Img: UIImageView!
    static func nib() -> UINib {
        return UINib(nibName: "ListViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        coll_label.isHidden = true
        // Initialization code
        
    }
    
    func configure(with model: Project){
        coll_label.isHidden = true
        collab_Img.isHidden = true
        if model.Image.isEmpty{
            return
        } else{
            self.ImageView.image = UIImage(data: model.Image)!
            self.model = model
        }
        if model.collabFlag == true{
            let path = DatabaseManager.GetImgPath(email: model.userList[0])
            StorageManager.shared.downloadURL(for: path, completion: { result in
                switch result {
                case .success(let url):
                    self.collab_Img.sd_setImage(with: url, completed: nil)
                    self.coll_label.isHidden = false
                    self.collab_Img.isHidden = false
                case .failure(let error):
                    print("Failed to get download url: \(error)")
                }
            })
        }
        
    }
    @IBAction func didTapShare(_ sender: Any) {
        delegate?.didTapShare(with: self.model)
    }
    
}
