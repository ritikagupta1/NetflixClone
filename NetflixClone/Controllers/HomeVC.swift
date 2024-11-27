//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class HomeVC: NetflixDataLoadingVC {
    
    var contentList: [Sections: [Content]] = [:]
    
    var sectionPaginationInfo: [Sections: PaginationInfo] = [:]
    
    var isLoadingFurtherContent = false
    
    var state: State = .loading {
        didSet {
            self.updateUI()
        }
    }
    
    private let homeFeedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTableView)
        configureNavBar()
        homeFeedTableView.dataSource = self
        homeFeedTableView.delegate = self
        homeFeedTableView.tableHeaderView = HeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 450))
        setupPullToRefresh()
        getAllContentData()
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        homeFeedTableView.refreshControl = refreshControl
    }

    @objc private func refreshData() {
        getAllContentData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTableView.frame = view.bounds
    }
    
    private func configureNavBar() {
        var image: UIImage = .netflixlogo
        image = image.withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(image: image, style: .done, target: self, action: nil), animated: false)
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil), UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)]
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func getAllContentData(page: Int = 1) {
        self.contentList = [:]
        state = .loading
        
        let dispatchGroup = DispatchGroup()
        var errorSections: [Sections] = []
        
        Sections.allCases.forEach { section in
            let call = getSectionCall(section: section)
            dispatchGroup.enter()
            
            call(page) { [weak self] result in
                guard let self = self else { return }
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let content):
                    self.contentList[section] = content.results
                    self.sectionPaginationInfo[section] = PaginationInfo(currentPage: content.page, totalPages: content.totalPages)
                case .failure(_):
                    errorSections.append(section)
                    self.contentList[section] = []
                }
            }
            
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            self.homeFeedTableView.refreshControl?.endRefreshing()
            // error for sections
            if !errorSections.isEmpty {
                self.state = .error(errorSections)
                self.homeFeedTableView.reloadData()
                self.view.bringSubviewToFront(self.homeFeedTableView)
                return
            }
            
            // completely empty
            if self.contentList.values.allSatisfy({ $0.isEmpty }) {
                self.state = .empty
                return
            }
            
            
            self.state = .loaded
            self.homeFeedTableView.reloadData()
            self.view.bringSubviewToFront(self.homeFeedTableView)
        }
    }
    
    func getSectionCall(section: Sections) -> (Int, @escaping (Result<ContentInfo, NetflixError>) -> Void) -> Void  {
        
        switch section {
        case .trendingMovies:
            return NetworkManager.shared.getTrendingMovies
        case .trendingTv:
            return NetworkManager.shared.getTrendingTv
        case .popular:
            return NetworkManager.shared.getUpcomingMovies
        case .upcomingMovies:
            return NetworkManager.shared.getUpcomingMovies
        case .topRated:
            return NetworkManager.shared.getTopRatedMovies
        }
    }
    
    private func reloadSpecificSection(_ section: Sections, page: Int = 1) {
        let call = getSectionCall(section: section)
        
        call(page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let content):
                    self.contentList[section] = content.results
                    self.sectionPaginationInfo[section] = PaginationInfo(currentPage: content.page, totalPages: content.totalPages)
                    // Reload the specific section
                    self.homeFeedTableView.reloadSections(IndexSet(integer: section.rawValue), with: .automatic)
                case .failure(_):
                    self.homeFeedTableView.reloadSections(IndexSet(integer: section.rawValue), with: .automatic)
                }
            }
        }
    }
    
    private func getMoreContent(for section: Sections) {
        guard let cell = homeFeedTableView.cellForRow(at: IndexPath(row: 0, section: section.rawValue)) as? HomeTableViewCell else { return }
        
        let call = getSectionCall(section: section)
        
        if self.sectionPaginationInfo[section]?.hasMoreContent ?? false, let page = self.sectionPaginationInfo[section]?.currentPage, !isLoadingFurtherContent {
            cell.loadingIndicator.startAnimating()
            isLoadingFurtherContent = true
            cell.collectionView.isUserInteractionEnabled = false
            let currentOffset = cell.collectionView.contentOffset
            
            call(page + 1) { [weak self] result in
                
                guard let self = self else { return }
                DispatchQueue.main.async {
                    cell.loadingIndicator.stopAnimating()
                    switch result {
                    case .success(let content):
                        var existingContent = self.contentList[section]
                        existingContent?.append(contentsOf: content.results)
                        self.contentList[section] = existingContent
                        self.sectionPaginationInfo[section] = PaginationInfo(currentPage: content.page, totalPages: content.totalPages)
                        if let cell = self.homeFeedTableView.cellForRow(at: IndexPath(row: 0, section: section.rawValue)) as? HomeTableViewCell,
                           let content = self.contentList[section] {
                            // Update data
                            cell.configure(with: content)
                            cell.collectionView.reloadData()
                            // Restore position
                            cell.collectionView.setContentOffset(currentOffset, animated: false)
                            
                        }
                        
                    case .failure(_):
                        self.homeFeedTableView.reloadSections(IndexSet(integer: section.rawValue), with: .none)
                    }
                    
                    cell.collectionView.isUserInteractionEnabled = true
                    self.isLoadingFurtherContent = false
                }
            }
        }
    }
    
    func updateUI() {
        switch state {
        case .loading:
            self.showLoadingView()
            
        case .loaded, .error:
            self.dismissLoadingIndicator()
            self.homeFeedTableView.isHidden = false
            
        case .empty:
            self.dismissLoadingIndicator()
            self.homeFeedTableView.isHidden = true
            self.showEmptyStateView(onRefresh: {
                // since this is for completely empty state, we need to refresh all data
                self.getAllContentData()
            })
        }
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell, let section = Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        cell.fetchNext = {
            self.getMoreContent(for: section)
        }
        
        if let content = contentList[section], !content.isEmpty {
            cell.configure(with: content)
        } else {
            cell.configureErrorState {
                self.reloadSpecificSection(section)
            }
        }
        
        return cell
                
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        headerView.textLabel?.textColor = .white
        headerView.textLabel?.font = UIFont.systemFont(ofSize: 18)
        headerView.textLabel?.text = headerView.textLabel?.text?.capitalized
        headerView.textLabel?.frame = CGRect(x: headerView.bounds.origin.x + 20, y: headerView.bounds.origin.y, width: 140, height: headerView.bounds.height)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Sections(rawValue: section)?.title
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = self.view.safeAreaInsets.top
        let actualOffset = scrollView.contentOffset.y + self.view.safeAreaInsets.top
        
        self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: 0, y: -max(0, min(defaultOffset, actualOffset)))
    }
}


enum State {
    case loading
    case loaded
    case empty
    case error([Sections])
}
