//
//  PhotosResponse.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/25/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: Photos?
    let stat: String
}

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
    
    subscript(index: Int) -> Photo? {
        if let photo = self.photo, numberOPhotos > index {
            return photo[index]
        } else {
            return nil
        }
    }
}
