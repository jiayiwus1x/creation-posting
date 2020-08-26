//
//  ListViewCell.swift
//  drawing
//
//  Created by Jiayi Wu on 8/19/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit
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
    static func nib() -> UINib {
        return UINib(nibName: "ListViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func configure(with model: Project){
        
        if model.Image.isEmpty{
        return
        } else{
            self.ImageView.image = UIImage(data: model.Image)!
            self.model = model
        }
    }
    @IBAction func didTapShare(_ sender: Any) {
        delegate?.didTapShare(with: self.model)
    }
  
}
