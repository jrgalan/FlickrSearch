//
//  PhotoTableViewCell.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/26/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var photoThumbnailImageView: UIImageView!
    
    private let placeholder = UIImage(named: "placeholder")
    private let processor = RoundCornerImageProcessor(cornerRadius: 8)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(title: String, thumbnailURL: String) {
        let url = URL(string: thumbnailURL)
        photoTitleLabel.text = title
        photoThumbnailImageView?.kf.setImage(with: url, placeholder: placeholder, options: [.processor(processor), .transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
    }

}
