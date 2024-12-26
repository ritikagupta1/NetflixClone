//
//  ViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.configure()
    }
    
    private func configure() {
        let homeVC = UINavigationController(rootViewController: HomeVC(viewModel: HomeViewModel()))
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let comingSoonVC = UINavigationController(rootViewController: ComingSoonVC(viewModel: ComingSoonViewModel()))
        comingSoonVC.tabBarItem = UITabBarItem(title: "Coming Soon", image: UIImage(systemName: "play.circle"), tag: 1)
        
        let topSearchesVC = UINavigationController(rootViewController: TopSearchesVC(viewModel: TopSearchViewModel()))
        topSearchesVC.tabBarItem = UITabBarItem(title: "Top Searches", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        
        let downloadsVC = UINavigationController(rootViewController: DownloadsVC(viewModel: DownloadViewModel()))
        downloadsVC.tabBarItem = UITabBarItem(title: "Downloads", image: UIImage(systemName: "arrow.down.to.line"), tag: 2)
        
        self.viewControllers = [homeVC, comingSoonVC, topSearchesVC, downloadsVC]
        UITabBar.appearance().tintColor = .label
    }


}

