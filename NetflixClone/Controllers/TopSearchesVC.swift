//
//  TopSearchesViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class TopSearchesVC: NetflixDataLoadingVC {
    var viewModel: TopSearchViewModel
    let rowHeight: CGFloat = 160
    
    let discoverTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .systemBackground
        tableview.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return tableview
    }()
    
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultsVC(viewModel: SearchResultsViewModel()))
        searchController.searchBar.placeholder = Constants.searchBarPlaceholder
        searchController.searchBar.searchBarStyle = .minimal
        return searchController
    }()
    
    init(viewModel: TopSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        discoverMovies()
    }
    
    private func configureViewController() {
        self.view.backgroundColor = .systemBackground
        self.title = Constants.searchScreenTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
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
    
    private func discoverMovies() {
        self.showLoadingView()
        self.viewModel.getTopSearchMovies { [weak self] success in
            guard let self = self else {
                return
            }
            self.dismissLoadingIndicator()
            if success {
                DispatchQueue.main.async {
                    self.discoverTableView.reloadData()
                }
            }
        }
    }
}

extension TopSearchesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: viewModel.getContent(for: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height

        if offSetY > contentHeight - height, viewModel.shouldLoadMore() {
            self.discoverMovies()
        }
    }
}

extension TopSearchesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchResultVC = searchController.searchResultsController as? SearchResultsVC else {
            return
        }
        let minimumQueryLength = 2
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, query.trimmingCharacters(in: .whitespaces).count > minimumQueryLength else {
            searchResultVC.viewModel.resetSearchResults()
            searchResultVC.searchCollectionView.reloadData()
            return
        }
        
        searchResultVC.viewModel.resetSearchResults()
        searchResultVC.showLoadingView()
        
        func handleSearchResults(result: Result<ContentInfo, NetflixError>) {
            searchResultVC.dismissLoadingIndicator()
            switch result {
            case .success(let content):
                DispatchQueue.main.async {
                    searchResultVC.viewModel.updateResults(with: content)
                    searchResultVC.searchCollectionView.reloadData()
                }
            
            case .failure(let error):
                print(error)
                searchResultVC.viewModel.resetSearchResults()
                searchResultVC.searchCollectionView.reloadData()
            }
        }
        
        searchResultVC.getMoreResults = { page in
            NetworkManager.shared.searchMovies(page: page, query: query, completion: handleSearchResults)
        }
        
        NetworkManager.shared.searchMovies(page: 1, query: query, completion: handleSearchResults)
    }
}
