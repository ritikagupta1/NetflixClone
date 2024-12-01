//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class HomeVC: NetflixDataLoadingVC {
    private let rowHeight: CGFloat = 200
    private let sectionHeaderHeight: CGFloat = 40
    private let headerHeight: CGFloat = 450
    
    var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let homeFeedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureTableview()
        self.viewModel.getAllContentData()
    }
    
    private func configureVC() {
        view.backgroundColor = .systemBackground
        configureNavBar()
        setupPullToRefresh()
    }
    
    private func configureNavBar() {
        var image: UIImage = .netflixlogo
        image = image.withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(image: image, style: .done, target: self, action: nil), animated: false)
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil), UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        homeFeedTableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        self.viewModel.getAllContentData()
    }
    
    private func configureTableview() {
        view.addSubview(homeFeedTableView)
        
        homeFeedTableView.dataSource = self
        homeFeedTableView.delegate = self
        homeFeedTableView.tableHeaderView = HeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: headerHeight))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTableView.frame = view.bounds
    }
    
    private func getMoreContent(for section: Sections) {
        guard let cell = homeFeedTableView.cellForRow(at: IndexPath(row: 0, section: section.rawValue)) as? HomeTableViewCell else { return }
        
        if viewModel.canFetchMoreContent(for: section) {
            cell.loadingIndicator.startAnimating()
            cell.collectionView.isUserInteractionEnabled = false
            let currentOffset = cell.collectionView.contentOffset
            
            viewModel.getMoreContent(for: section, completion: { success in
                cell.loadingIndicator.stopAnimating()
                guard success else {
                    self.homeFeedTableView.reloadSections(IndexSet(integer: section.rawValue), with: .none)
                    return
                }
                
                if let cell = self.homeFeedTableView.cellForRow(at: IndexPath(row: 0, section: section.rawValue)) as? HomeTableViewCell,
                   let content = self.viewModel.contentList[section] {
                    // Update data
                    cell.configure(with: content, section: section)
                    cell.collectionView.reloadData()
                    // Restore position
                    cell.collectionView.setContentOffset(currentOffset, animated: false)
                    
                }
                
                cell.collectionView.isUserInteractionEnabled = true
            })
        }
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell, let section = Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.fetchNext = {
            self.getMoreContent(for: section)
        }
        
        if let content = viewModel.contentList[section], !content.isEmpty {
            cell.configure(with: content, section: section)
        } else {
            cell.configureErrorState {
                self.viewModel.reloadSpecificSection(section)
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
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
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

extension HomeVC: HomeViewModelDelegate {
    func updateUI(with state: State) {
        self.homeFeedTableView.refreshControl?.endRefreshing()
        
        switch state {
        case .loading:
            self.showLoadingView()
            
        case .loaded, .error:
            self.dismissLoadingIndicator()
            self.homeFeedTableView.isHidden = false
            self.homeFeedTableView.reloadData()
            self.view.bringSubviewToFront(self.homeFeedTableView)
            
        case .empty:
            self.dismissLoadingIndicator()
            self.homeFeedTableView.isHidden = true
            self.showEmptyStateView(onRefresh: {
                // since this is for completely empty state, we need to refresh all data
                self.viewModel.getAllContentData()
            })
        }
    }
    
    func reloadSection(index: IndexSet) {
        self.homeFeedTableView.reloadSections(index, with: .automatic)
    }
}

extension HomeVC: HomeTableViewCellDelegate {
    func didTapCell(in section: Sections, at index: Int) {
        let content = self.viewModel.contentList[section]?[index]
        let model = ContentPreviewModel(contentTitle: content?.originalTitle ?? content?.originalName ?? "Unknown", contentOverView: content?.overview ?? "Unknown")
        let contentPreviewVC = ContentPreviewViewController()
        contentPreviewVC.configure(with: model)
        self.navigationController?.pushViewController(contentPreviewVC, animated: true)
    }

}
