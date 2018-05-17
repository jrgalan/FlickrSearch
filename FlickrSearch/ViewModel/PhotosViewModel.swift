//
//  PhotosViewModel.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/27/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

final class PhotosViewModel {
    
    private let flickrAPIManager: FlickrAPIManager
    private var pagedArray: PagedArray<Photo>?
    private var isLoading = false
    private let startingPage = 1
    private let nextPageThreshold = 5
    private let recentSearchesKey = "recentSearches"
    
    var numberOfPhotos: Int {
        if let pagedArray = self.pagedArray {
            return pagedArray.count
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
        return pagedArray?[index]
    }
    
    func likedPhoto(index: Int) {
        if var photo = pagedArray?[index] {
            photo.liked()
            pagedArray?.updateElement(photo, index: index)
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
        if !searchTerm.isEmpty {
            clearCurrentPhotos()
            addRecentSearch(searchTerm: searchTerm)
            performFlickrSearch(searchTerm: searchTerm, page: startingPage) { success in
                completion(success)
            }
        }
    }
    
    func shouldFetchNextPage(for index: Int, searchTerm: String, completion: @escaping (Bool) -> Void) {
        if !isLoading, let pagedArray = self.pagedArray, pagedArray.count - nextPageThreshold < index {
            fetchNextPage(searchTerm: searchTerm) { success in
                completion(success)
            }
        }
    }
    
    func clearCurrentPhotos() {
        pagedArray = nil
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
        flickrAPIManager.searchPhotos(page: page, searchTerm: searchTerm) { photosResult in
            switch photosResult {
            case .failure:
                completion(false)
            case .success(let value):
                if let photos = value.photo {
                    if self.pagedArray == nil {
                        self.pagedArray = PagedArray(totalCount: Int(value.total)!, pageSize: value.perpage, pages: value.pages)
                    }
                    self.pagedArray?.addElements(photos, pageIndex: value.page)
                }
                completion(true)
            }
            self.isLoading = false
        }
    }
    
    func fetchNextPage(searchTerm: String, completion: @escaping (Bool) -> Void) {
        if let pagedArray = self.pagedArray, pagedArray.pages > pagedArray.currentPage {
            performFlickrSearch(searchTerm: searchTerm, page: pagedArray.currentPage + 1) { success in
                completion(success)
            }
        }
    }
}
