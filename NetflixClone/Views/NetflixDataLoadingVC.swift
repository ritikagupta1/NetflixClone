//
//  NetflixDataLoadingVC.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 19/11/24.
//

import UIKit

class NetflixDataLoadingVC: UIViewController {
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0.0
        
        self.view.addSubview(containerView)
        
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.containerView.alpha = 0.0
                self.containerView.removeFromSuperview()
                self.containerView = nil
            }
        }
    }
    
    func showEmptyStateView(onRefresh: @escaping (() -> Void)) {
        let emptyStateView = EmptyStateView()
        emptyStateView.onRefresh = onRefresh
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
}
