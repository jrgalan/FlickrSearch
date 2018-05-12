//
//  PhotoDetailViewController.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/26/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoDetailViewController: UIViewController {

    var photoTitle: String?
    var urlString: String?
    
    @IBOutlet weak var mainImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = photoTitle
        loadMainImage()
    }
    
    func loadMainImage() {
        if let safeURL = urlString {
            let url = URL(string: safeURL)
            mainImageView.kf.setImage(with: url)
        }
    }

}
