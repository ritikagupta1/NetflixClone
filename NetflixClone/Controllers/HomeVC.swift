//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class HomeVC: UIViewController {
    private let sectionsTitles: [String] = ["Trending Movies", "Popular", "Trending TV", "Upcoming Movies", "Top Rated"]
    private let homeFeedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
       
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(homeFeedTableView)
        configureNavBar()
        homeFeedTableView.dataSource = self
        homeFeedTableView.delegate = self
        homeFeedTableView.tableHeaderView = HeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 450))
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
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        return cell
                
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionsTitles.count
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
        sectionsTitles[section]
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = self.view.safeAreaInsets.top
        let actualOffset = scrollView.contentOffset.y + self.view.safeAreaInsets.top
        
        self.navigationController?.navigationBar.transform = CGAffineTransform(translationX: 0, y: -max(0, min(defaultOffset, actualOffset)))
    }
}
