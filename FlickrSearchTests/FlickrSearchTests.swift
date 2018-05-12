//
//  FlickrSearchTests.swift
//  FlickrSearchTests
//
//  Created by Jensen Galan on 4/25/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class FlickrSearchTests: XCTestCase {
    
    let photoResponseJSON = """
        {
        "photos":
            {"page":1,"pages":10106,"perpage":25,"total":"252644","photo":
                [
                    {"id":"41766756641","owner":"42674227@N08","secret":"847d58b9e7","server":"978","farm":1,"title":"Cardiff Queens Vaults Pub Sign","ispublic":1,"isfriend":0,"isfamily":0}
                ]
            }
        ,"stat":"ok"
        }
        """.data(using: .utf8)!
    
    var photosResponse: PhotosResponse?
    var photosViewModel: PhotosViewModel!
    
    override func setUp() {
        super.setUp()
        do {
            photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: photoResponseJSON)
        } catch let jsonError {
            XCTFail("Decoding error: \(jsonError.localizedDescription)")
        }
        photosViewModel = PhotosViewModel(flickrAPIManager: MockFlickrAPIManager())
        photosViewModel.performSearch(searchTerm: "Bleacher Report") { success in }
    }
    
    override func tearDown() {
        photosResponse = nil
        photosViewModel = nil
        super.tearDown()
    }
    
    func testPhotosResponsePage() {
        if let safePhotosResponse = photosResponse {
            XCTAssertEqual(safePhotosResponse.photos?.page, 1, "PhotosResponse page wrong")
        } else {
            XCTFail("photosResponse nil")
        }
    }
    
    func testPhotosResponsePages() {
        if let safePhotosResponse = photosResponse {
            XCTAssertEqual(safePhotosResponse.photos?.pages, 10106, "PhotosResponse pages wrong")
        } else {
            XCTFail("photosResponse nil")
        }
    }
    
    func testPhotosResponsePerPage() {
        if let safePhotosResponse = photosResponse {
            XCTAssertEqual(safePhotosResponse.photos?.perpage, 25, "PhotosResponse per page wrong")
        } else {
            XCTFail("photosResponse nil")
        }
    }
    
    func testPhotosResponseTotal() {
        if let safePhotosResponse = photosResponse {
            XCTAssertEqual(safePhotosResponse.photos?.total, "252644", "PhotosResponse total wrong")
        } else {
            XCTFail("photosResponse nil")
        }
    }
    
    func testPhotosNumberOfPhotos() {
        if let photos = photosResponse?.photos {
            XCTAssertEqual(photos.numberOPhotos, 1, "Photos numberOfPhotos wrong")
        } else {
            XCTFail("photos nil")
        }
    }
    
    func testPhotoThumbnailURL() {
        if let photo = photosResponse?.photos?.photo?.first {
            XCTAssertEqual(photo.photoThumbnailURL, "https://farm1.staticflickr.com/978/41766756641_847d58b9e7_s.jpg", "Photo Thumbnail URL wrong")
        } else {
            XCTFail("photo nil")
        }
    }
    
    func testPhotoLargeURL() {
        if let photo = photosResponse?.photos?.photo?.first {
            XCTAssertEqual(photo.photoLargeURL, "https://farm1.staticflickr.com/978/41766756641_847d58b9e7_b.jpg", "Photo Large URL wrong")
        } else {
            XCTFail("photo nil")
        }
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
        photosViewModel.performSearch(searchTerm: "Simms & Lefkoe") { success in }
        let numberOfPhotos = photosViewModel.numberOfPhotos
        XCTAssertEqual(numberOfPhotos, 1, "PhotosViewModel numberOfPhotos wrong after searching")
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
    
    override func searchPhotos(page: Int, searchTerm: String, completion: @escaping (Photos?, Error?) -> Void) {
        do {
            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: photoResponseJSON)
            if let photos = photosResponse.photos {
                completion(photos, nil)
            } else {
                completion(nil, FlickrAPIError.noPhotos)
            }
        } catch let jsonError {
            XCTFail("Decoding error: \(jsonError.localizedDescription)")
        }
    }
}

