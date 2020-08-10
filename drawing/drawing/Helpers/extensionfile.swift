//
//  extensionfile.swift
//  drawing
//
//  Created by Jiayi Wu on 8/10/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit

class extensionfile: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

public extension UIColor{

    var codedString: String?{
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)

            return data.base64EncodedString()

        }
        catch let error{
            print("Error converting color to coded string: \(error)")
            return nil
        }
    }


    static func color(withCodedString string: String) -> UIColor?{
        guard let data = Data(base64Encoded: string) else{
            return nil
        }

        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)

    }
}
extension UIView {

    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}


extension UIImage {
    func getImageRatio() -> CGFloat {
        let imageRatio = CGFloat(self.size.width / self.size.height)
        return imageRatio
    }
}
