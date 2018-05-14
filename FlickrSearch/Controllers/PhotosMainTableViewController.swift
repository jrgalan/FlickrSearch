//
//  PhotosMainTableViewController.swift
//  FlickrSearch
//
//  Created by Jensen Galan on 4/25/18.
//  Copyright © 2018 Miki Apps. All rights reserved.
//

import UIKit

class PhotosMainTableViewController: UITableViewController {
    
    // Constants
    private let photoCellPrototype = "PhotoCell"
    private let recentSearchPrototype = "RecentSearchCell"
    private let numberOfRowsSearching = 0
    private let recentSearchHeaderHeight: CGFloat = 50.0
    private let recentSearchRowHeight: CGFloat = 60.0
    private let photoRowHeight: CGFloat = 100.0
    
    enum PhotosDisplayState {
        case displayingRecentSearch
        case loading
        case displayingResults
    }
    
    private var photosDisplayState: PhotosDisplayState = .displayingRecentSearch {
        didSet {
            switch photosDisplayState {
            case .displayingRecentSearch:
                DispatchQueue.main.async { [weak self] in
                    self?.indicator.stopAnimating()
                }
            case .loading:
                DispatchQueue.main.async { [weak self] in
                    self?.indicator.startAnimating()
                }
            case .displayingResults:
                DispatchQueue.main.async { [weak self] in
                    self?.indicator.stopAnimating()
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
        }
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let photosViewModel = PhotosViewModel(flickrAPIManager: FlickrAPIManager())
    
    private var searchTerm: String?
    
    private var indicator = UIActivityIndicatorView()
    
    // MARK: - Controller view setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationAppearance()
        setupSearchController()
        setupActivityIndicator()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch photosDisplayState {
        case .displayingRecentSearch:
            return photosViewModel.numberOfRecentSearches
        case .loading:
            return numberOfRowsSearching
        case .displayingResults:
            return photosViewModel.numberOfPhotos
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let prototype = prototypeIdentifierForCurrentTable()
        let cell = tableView.dequeueReusableCell(withIdentifier: prototype, for: indexPath)
        
        if let photoCell = cell as? PhotoTableViewCell, let photo = photosViewModel.photo(for: indexPath.row) {
            photoCell.setupCell(title: photo.title, thumbnailURL: photo.photoThumbnailURL)
        } else {
            cell.textLabel?.text = photosViewModel.recentSearchTerm(for: indexPath.row)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let safeSearchTerm = searchTerm {
            photosViewModel.shouldFetchNextPage(for: indexPath.row, searchTerm: safeSearchTerm, completion: { success in
                self.handleSearchResult(success: success)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch photosDisplayState {
        case .displayingRecentSearch:
            return recentSearchRowHeight
        case .displayingResults:
            return photoRowHeight
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch photosDisplayState {
        case .displayingRecentSearch:
            performRecentSearch(index: indexPath.row)
        case .displayingResults:
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch photosDisplayState {
        case .displayingRecentSearch:
            return recentSearchHeaderHeight
        default:
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch photosDisplayState {
        case .displayingRecentSearch:
            return "Recent"
        default:
            return nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "PhotoDetailSegue":
                if let cell = sender as? PhotoTableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let photo = photosViewModel.photo(for: indexPath.row),
                    let photoDetailController = segue.destination as? PhotoDetailViewController {
                    photoDetailController.photoTitle = photo.title
                    photoDetailController.urlString = photo.photoLargeURL
                }
            default:
                break
            }
        }
    }
}

extension PhotosMainTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text {
            searchTerm = searchText
            performSearch(searchTerm: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTerm = nil
        photosViewModel.clearCurrentPhotos()
        photosDisplayState = .displayingRecentSearch
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let safeSearchTerm = searchTerm, !safeSearchTerm.isEmpty {
            searchBar.text = searchTerm
        }
    }
}

private extension PhotosMainTableViewController {
    
    func setupTableView() {
        // The ol' "remove empty cells" trick ;)
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationAppearance() {
        title = "flickr findr"
        navigationController?.navigationBar.barTintColor = .flickrLightBlue
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupSearchController() {
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.barTintColor = .flickrLightBlue
        searchController.searchBar.placeholder = "Search Images"
        searchController.searchBar.tintColor = .darkGray
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setupActivityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.color = .gray
        indicator.center = view.center
        view.addSubview(indicator)
    }
    
    func performSearch(searchTerm: String) {
        if !searchTerm.isEmpty {
            searchController.isActive = false
            photosDisplayState = .loading
            photosViewModel.performSearch(searchTerm: searchTerm) { success in
                self.handleSearchResult(success: success)
            }
        }
    }
    
    func performRecentSearch(index: Int) {
        if let recentSearchTerm = photosViewModel.recentSearchTerm(for: index) {
            searchTerm = recentSearchTerm
            searchController.searchBar.text = searchTerm
            photosDisplayState = .loading
            photosViewModel.performSearch(searchTerm: recentSearchTerm) { success in
                self.handleSearchResult(success: success)
            }
        }
    }
    
    func handleSearchResult(success: Bool) {
        if success, photosViewModel.numberOfPhotos > 0 {
            photosDisplayState = .displayingResults
        } else {
            photosDisplayState = .displayingRecentSearch
            showErrorAlert()
        }
    }
    
    func prototypeIdentifierForCurrentTable() -> String {
        switch photosDisplayState {
        case .displayingResults:
            return photoCellPrototype
        default:
            return recentSearchPrototype
        }
    }
    
    func showErrorAlert() {
        let alertController = UIAlertController(title: "No results", message: "Please try a different search", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
