//
//  PagedArrayTests.swift
//  FlickrSearchTests
//
//  Created by Jensen Galan on 5/13/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class PagedArrayTests: XCTestCase {
    
    var pagedArray: PagedArray<Int>!
    
    override func setUp() {
        super.setUp()
        pagedArray = PagedArray(totalCount: 2, pageSize: 1, pages: 2)
        pagedArray.addElements([1], pageIndex: 1)
    }
    
    override func tearDown() {
        pagedArray = nil
        super.tearDown()
    }

    func testPageSize() {
        XCTAssertEqual(pagedArray.pageSize, 1, "PagedArray pageSize wrong")
    }
    
    func testTotalCount() {
        XCTAssertEqual(pagedArray.totalCount, 2, "PagedArray totalCount wrong")
    }
    
    func testPages() {
        XCTAssertEqual(pagedArray.pages, 2, "PagedArray pages wrong")
    }
    
    func testCurrentPage() {
        XCTAssertEqual(pagedArray.currentPage, 1, "PagedArray currentPage wrong")
    }
    
    func testAddElements() {
        XCTAssertEqual(pagedArray.count, 1, "PagedArray count wrong")
    }
    
    func testIndexElement() {
        if let element = pagedArray[0] {
            XCTAssertEqual(element, 1, "PagedArray element wrong")
        } else {
            XCTFail("element nil")
        }
    }
    
    func testUpdateElement() {
        pagedArray.updateElement(2, index: 0)
        if let element = pagedArray[0] {
            XCTAssertEqual(element, 2, "PagedArray updated element wrong")
        } else {
            XCTFail("element nil")
        }
    }
    
}
