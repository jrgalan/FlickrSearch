//
//  Result.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 5/13/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}
