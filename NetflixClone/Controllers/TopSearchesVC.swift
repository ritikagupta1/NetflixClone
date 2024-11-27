//
//  TopSearchesViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class TopSearchesVC: NetflixDataLoadingVC {
    var topSearchMovies: [Content] = []
    var isLoadingMovies: Bool = false
    var hasMoreMovies: Bool = true
    var page: Int = 1
    
    let discoverTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .systemBackground
        tableview.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return tableview
    }()
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultsVC())
        searchController.searchBar.placeholder = "Search for movies"
        searchController.searchBar.searchBarStyle = .minimal
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        configureViewController()
        configureTableView()
        discoverMovies()
    }
    
    private func configureViewController() {
        self.view.backgroundColor = .systemBackground
        self.title = "Search"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureTableView() {
        self.view.addSubview(discoverTableView)
        
        self.discoverTableView.delegate = self
        self.discoverTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTableView.frame = view.bounds
    }
    
    func discoverMovies() {
        self.showLoadingView()
        self.isLoadingMovies = true
        NetworkManager.shared.discoverMovies(page: page) { [weak self] result in
            self?.isLoadingMovies = false
            guard let self = self else {
                return
            }
            self.dismissLoadingIndicator()
            switch result {
            case .success(let content):
                DispatchQueue.main.async {
                    self.topSearchMovies.append(contentsOf: content.results)
                    self.hasMoreMovies = content.page < content.totalPages
                    self.discoverTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension TopSearchesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topSearchMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: topSearchMovies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height

        if offSetY > contentHeight - height, !isLoadingMovies, hasMoreMovies {
            self.page += 1
            self.discoverMovies()
        }
    }
}

extension TopSearchesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchResultVC = searchController.searchResultsController as? SearchResultsVC else {
            return
        }
        
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, query.trimmingCharacters(in: .whitespaces).count > 2 else {
            searchResultVC.searchResults.removeAll()
            searchResultVC.page = 1
            searchResultVC.searchCollectionView.reloadData()
            return
        }
        
        searchResultVC.searchResults.removeAll()
        searchResultVC.page = 1
        searchResultVC.showLoadingView()
        
        func handleSearchResults(result: Result<ContentInfo, NetflixError>) {
            searchResultVC.isLoadingSearchResults = false
            searchResultVC.dismissLoadingIndicator()
            switch result {
            case .success(let content):
                DispatchQueue.main.async {
                    searchResultVC.hasMoreSearchResults = content.page < content.totalPages
                    searchResultVC.searchResults.append(contentsOf: content.results)
                    searchResultVC.searchCollectionView.reloadData()
                }
            
            case .failure(let error):
                print(error)
                searchResultVC.searchResults.removeAll()
                searchResultVC.searchCollectionView.reloadData()
            }
        }
        
        searchResultVC.getMoreResults = { page in
            NetworkManager.shared.searchMovies(page: page, query: query, completion: handleSearchResults)
        }
        
        NetworkManager.shared.searchMovies(page: page, query: query, completion: handleSearchResults)
    }
}
