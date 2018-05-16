//
//  FlickrAPIManager.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/26/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import Foundation

class FlickrAPIManager {
    
    enum FlickrAPIError: Error {
        case noData
        case noPhotos
        case failed
        case jsonError
    }
    
    private let kFlickrAPIKey = ""
    private let photosPerPage = 25
    
    func searchPhotos(page: Int, searchTerm: String, completion: @escaping (Result<Photos>) -> Void) {
        let massagedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(kFlickrAPIKey)&text=\(massagedSearchTerm)&per_page=\(photosPerPage)&page=\(page)&format=json&nojsoncallback=1"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(FlickrAPIError.noData))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
                        if let photos = photosResponse.photos {
                            completion(.success(photos))
                        } else {
                            completion(.failure(FlickrAPIError.noPhotos))
                        }
                    } catch {
                        completion(.failure(FlickrAPIError.jsonError))
                    }
                default:
                    completion(.failure(FlickrAPIError.failed))
                }
            } else {
                completion(.failure(FlickrAPIError.failed))
            }
        }.resume()
    }
    
}
