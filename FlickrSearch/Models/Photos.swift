//
//  Photos.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 5/14/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]?
}

extension Photos {
    
    var numberOPhotos: Int {
        if let photo = self.photo {
            return photo.count
        } else {
            return 0
        }
    }
    
}
