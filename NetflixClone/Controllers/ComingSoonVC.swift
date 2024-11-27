//
//  ComingSoonViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class ComingSoonVC: NetflixDataLoadingVC {
    var upcomingMovies: [Content] = []
    var isLoadingMovies: Bool = false
    var hasMoreMovies: Bool = true
    var page: Int = 1
    
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
        self.title = "Upcoming"
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
        self.isLoadingMovies = true
        NetworkManager.shared.getUpcomingMovies(page: page) { [weak self] result in
            self?.isLoadingMovies = false
            guard let self = self else {
                return
            }
            self.dismissLoadingIndicator()
            switch result {
            case .success(let content):
                DispatchQueue.main.async {
                    self.upcomingMovies.append(contentsOf: content.results)
                    self.hasMoreMovies = content.page < content.totalPages
                    self.upcomingTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ComingSoonVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        upcomingMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(with: upcomingMovies[indexPath.row])
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
            self.getUpcomingMovies()
        }
    }
}
