//
//  PhotosViewModelTests.swift
//  FlickrSearchTests
//
//  Created by Jensen Galan on 5/13/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class PhotosViewModelTests: XCTestCase {
    
    var photosViewModel: PhotosViewModel!
    
    override func setUp() {
        super.setUp()
        photosViewModel = PhotosViewModel(flickrAPIManager: MockFlickrAPIManager())
        photosViewModel.performSearch(searchTerm: "Bleacher Report") { _ in }
    }
    
    override func tearDown() {
        photosViewModel = nil
        super.tearDown()
    }
    
    func testNumberOfPhotos() {
        let numberOfPhotos = photosViewModel.numberOfPhotos
        XCTAssertEqual(numberOfPhotos, 1, "PhotosViewModel numberOfPhotos wrong")
    }
    
    func testPhotoTitle() {
        let photo = photosViewModel.photo(for: 0)
        XCTAssertEqual(photo?.title, "Buick re-hires Tiger Woods", "PhotosViewModel photo title wrong")
    }
    
    func testClearPhotos() {
        photosViewModel.clearCurrentPhotos()
        let numberOfPhotos = photosViewModel.numberOfPhotos
        XCTAssertEqual(numberOfPhotos, 0, "PhotosViewModel numberOfPhotos wrong after clearing")
    }
    
    func testPerformSearch() {
        photosViewModel.performSearch(searchTerm: "Simms & Lefkoe") { _ in }
        let numberOfPhotos = photosViewModel.numberOfPhotos
        XCTAssertEqual(numberOfPhotos, 1, "PhotosViewModel numberOfPhotos wrong after searching")
    }
    
    func testLikedPhoto() {
        photosViewModel.likedPhoto(index: 0)
        let photo = photosViewModel.photo(for: 0)
        XCTAssert(photo?.isLiked == true, "PhotosViewModel photo not liked correctly")
    }
    
}

class MockFlickrAPIManager: FlickrAPIManager {
    
    let photoResponseJSON = """
        {
        "photos":
            {"page":1,"pages":10106,"perpage":25,"total":"252644","photo":
                [
                    {"id":"26777141167","owner":"159226766@N06","secret":"f21dd5715f","server":"825","farm":1,"title":"Buick re-hires Tiger Woods","ispublic":1,"isfriend":0,"isfamily":0}
                ]
            }
        ,"stat":"ok"
        }
        """.data(using: .utf8)!
    
    override func searchPhotos(page: Int, searchTerm: String, completion: @escaping (Result<Photos>) -> Void) {
        do {
            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: photoResponseJSON)
            if let photos = photosResponse.photos {
                completion(.success(photos))
            } else {
                completion(.failure(FlickrAPIError.noPhotos))
            }
        } catch let jsonError {
            XCTFail("Decoding error: \(jsonError.localizedDescription)")
        }
    }
}
