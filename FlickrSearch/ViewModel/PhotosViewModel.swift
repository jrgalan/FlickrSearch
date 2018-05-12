//
//  PhotosViewModel.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/27/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

class PhotosViewModel {
    
    private let flickrAPIManager: FlickrAPIManager
    private var photos: Photos?
    private var photoData: [Photo]?
    private var isLoading = false
    private var currentPage = 1
    private let nextPageThreshold = 5
    private let recentSearchesKey = "recentSearches"
    
    var numberOfPhotos: Int {
        if let safePhotoData = photoData {
            return safePhotoData.count
        } else {
            return 0
        }
    }
    
    var numberOfRecentSearches: Int {
        let recentSearchStrings = recentSearches
        return recentSearchStrings.count
    }
    
    required init(flickrAPIManager: FlickrAPIManager) {
        self.flickrAPIManager = flickrAPIManager
        UserDefaults.standard.register(defaults: [recentSearchesKey: []])
    }
    
    func photo(for index: Int) -> Photo? {
        if let safePhotoData = photoData, safePhotoData.count > index {
            return safePhotoData[index]
        } else {
            return nil
        }
    }
    
    func recentSearchTerm(for index: Int) -> String? {
        let recentSearchStrings = recentSearches
        if index < recentSearchStrings.count {
            return recentSearchStrings[index]
        } else {
            return nil
        }
    }
    
    func performSearch(searchTerm: String, completion: @escaping (Bool) -> Void) {
        if searchTerm.count > 0 {
            currentPage = 1
            addRecentSearch(searchTerm: searchTerm)
            performFlickrSearch(searchTerm: searchTerm, page: currentPage) { success in
                completion(success)
            }
        }
    }
    
    func shouldFetchNextPage(for index: Int, searchTerm: String, completion: @escaping (Bool) -> Void) {
        if !isLoading, let safePhotoData = photoData, safePhotoData.count - nextPageThreshold < index {
            fetchNextPage(searchTerm: searchTerm) { success in
                completion(success)
            }
        }
    }
    
    func clearCurrentPhotos() {
        photos = nil
        photoData = nil
    }
    
}

private extension PhotosViewModel {
    
    var recentSearches: [String] {
        if let recentSearchStrings = UserDefaults.standard.object(forKey: recentSearchesKey) as? [String] {
            return recentSearchStrings
        } else {
            return [""]
        }
    }
    
    func addRecentSearch(searchTerm: String) {
        var recentSearchStrings = UserDefaults.standard.object(forKey: recentSearchesKey) as? [String] ?? [String]()
        recentSearchStrings.insert(searchTerm, at: 0)
        UserDefaults.standard.set(recentSearchStrings, forKey: recentSearchesKey)
    }
    
    func performFlickrSearch(searchTerm: String, page: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        flickrAPIManager.searchPhotos(page: page, searchTerm: searchTerm) { photosResult, error in
            if let photos = photosResult {
                self.photos = photos
                if page > 1, let safePhotoData = photos.photo {
                    self.photoData?.append(contentsOf: safePhotoData)
                } else {
                    self.photoData = photos.photo
                }
                completion(true)
            } else {
                completion(false)
            }
            self.isLoading = false
        }
    }
    
    func fetchNextPage(searchTerm: String, completion: @escaping (Bool) -> Void) {
        currentPage += 1
        if let safePhotos = photos, currentPage < safePhotos.pages {
            performFlickrSearch(searchTerm: searchTerm, page: currentPage) { success in
                completion(success)
            }
        }
    }
}

