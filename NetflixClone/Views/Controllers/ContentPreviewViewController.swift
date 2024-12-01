//
//  ContentPreviewViewController.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 30/11/24.
//

import UIKit
import WebKit

class ContentPreviewViewController: NetflixDataLoadingVC {
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .systemBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private var webView: WKWebView = {
        var webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22)
        return label
    }()
    
    private var overViewLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private var downloadButton: UIButton = {
        var button = UIButton()
        button.setTitle(Constants.downloadButtonTitle, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = false
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = false // Ensure back button is not hidden
        webView.stopLoading()
    }
    
    func configureView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(webView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(overViewLabel)
        contentView.addSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            
            webView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 280),
            
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            overViewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            overViewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            overViewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            downloadButton.topAnchor.constraint(equalTo: overViewLabel.bottomAnchor, constant: 20),
            downloadButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            downloadButton.heightAnchor.constraint(equalToConstant: 50),
            downloadButton.widthAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    deinit {
        webView.stopLoading()
        webView.navigationDelegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.stopLoading()
    }
    
    func configure(with model: ContentPreviewModel) {
        self.titleLabel.text = model.contentTitle
        self.overViewLabel.text = model.contentOverView
        self.showLoadingView()
        NetworkManager.shared.getMovieTrailer(query: "\(model.contentTitle) trailer") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismissLoadingIndicator()
                
                switch result {
                case .success(let trailerResponse):
                    let urlString = "https://www.youtube.com/embed/\(trailerResponse.items.first?.id.videoId ?? "In8fuzj3gck")"
                    
                    guard let url = URL(string: urlString) else {
                        print("Invalid URL")
                        return
                    }
                    
                    self.webView.load(URLRequest(url: url))
                    
                case .failure(let error):
                    print("Trailer fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
}
