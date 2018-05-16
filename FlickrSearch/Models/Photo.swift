//
//  Photo.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/25/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

struct Photo: Codable, Likeable {
    let id, owner, secret, server, title: String
    let farm, ispublic, isfriend, isfamily: Int
    var isLiked: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.owner = try container.decode(String.self, forKey: .owner)
        self.secret = try container.decode(String.self, forKey: .secret)
        self.server = try container.decode(String.self, forKey: .server)
        self.title = try container.decode(String.self, forKey: .title)
        self.farm = try container.decode(Int.self, forKey: .farm)
        self.ispublic = try container.decode(Int.self, forKey: .ispublic)
        self.isfriend = try container.decode(Int.self, forKey: .isfriend)
        self.isfamily = try container.decode(Int.self, forKey: .isfamily)
        self.isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
    }
}

extension Photo {
    var photoThumbnailURL: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_s.jpg"
    }
    
    var photoLargeURL: String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg"
    }
}
