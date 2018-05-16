//
//  PagedArray.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 5/12/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

struct PagedArray<T> {
    
    typealias PageIndex = Int
    typealias Index = Int
    
    private var elements = [T]()
    let pageSize: Int
    let totalCount: Int
    let pages: Int
    var currentPage = 0
    
    var count: Int {
        return elements.count
    }
    
    init(totalCount: Int, pageSize: Int, pages: Int, pageIndex: PageIndex = 1) {
        self.totalCount = totalCount
        self.pageSize = pageSize
        self.pages = pages
        self.currentPage = pageIndex
    }
    
    subscript(index: Index) -> T? {
        get {
            return elements.count > index ? elements[index] : nil
        }
        set {
            guard let newValue = newValue else { return }
            elements[index] = newValue
        }
    }

    mutating func addElements(_ elements: [T], pageIndex: PageIndex) {
        currentPage = pageIndex
        self.elements.append(contentsOf: elements)
    }
    
}
