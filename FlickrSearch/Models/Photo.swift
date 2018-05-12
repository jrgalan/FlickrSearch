//
//  Photo.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/25/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id, owner, secret, server, title: String
    let farm, ispublic, isfriend, isfamily: Int
}

extension Photo {
    var photoThumbnailURL: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_s.jpg"
    }
    
    var photoLargeURL: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg"
    }
}
