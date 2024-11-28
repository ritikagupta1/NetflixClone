//
//  ComingSoonViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class ComingSoonVC: NetflixDataLoadingVC {
    var viewModel: ComingSoonViewModel
    let rowHeight: CGFloat = 160
    
    init(viewModel: ComingSoonViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let upcomingTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .systemBackground
        tableview.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return tableview
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()
        self.configureTableView()
        self.getUpcomingMovies()
    }
    
    private func configureViewController() {
        self.view.backgroundColor = .systemBackground
        self.title = Constants.upcomingScreenTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func configureTableView() {
        self.view.addSubview(upcomingTableView)
        
        self.upcomingTableView.delegate = self
        self.upcomingTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTableView.frame = view.bounds
    }
    
    private func getUpcomingMovies() {
        self.showLoadingView()
        self.viewModel.getUpcomingMovies() { [weak self] success in
            guard let self = self else {
                return
            }
            self.dismissLoadingIndicator()
            if success {
                DispatchQueue.main.async {
                    self.upcomingTableView.reloadData()
                }
            }
        }
    }
}

extension ComingSoonVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: self.viewModel.getContent(for: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offSetY > contentHeight - height && viewModel.shouldLoadMore() {
            self.getUpcomingMovies()
        }
    }
}
