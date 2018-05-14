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
