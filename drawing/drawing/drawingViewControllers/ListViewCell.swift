//
//  ListViewCell.swift
//  drawing
//
//  Created by Jiayi Wu on 8/19/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit

class ListViewCell: UITableViewCell {
    static let identifier = "ListViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "ListViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
