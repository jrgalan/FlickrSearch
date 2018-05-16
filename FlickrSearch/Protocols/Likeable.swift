//
//  Likeable.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 5/15/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

protocol Likeable {
    var isLiked: Bool { get set }
    mutating func liked()
    mutating func unliked()
}

extension Likeable {
    mutating func liked() {
        isLiked = true
    }
    
    mutating func unliked() {
        isLiked = false
    }
}
