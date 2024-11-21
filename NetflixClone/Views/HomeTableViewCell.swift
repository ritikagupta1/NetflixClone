//
//  HomeTableViewCell.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    static let identifier = "HomeTableViewCell"
    
    var content: [Content] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .systemRed
        return imageView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .systemPurple
        contentView.addSubview(collectionView)
        contentView.addSubview(errorView)
        errorView.addSubview(errorImageView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Collection View
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Error View
            errorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Error Image View
            errorImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorImageView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -40),
            errorImageView.widthAnchor.constraint(equalToConstant: 50),
            errorImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Error Label
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -20),
            
            // Retry Button
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: 140, height: self.contentView.bounds.height)
    }
    
    func configure(with content: [Content]) {
        self.content = content
        self.collectionView.reloadData()
        self.errorView.isHidden = true
        self.collectionView.isHidden = false
    }
    
    override func prepareForReuse() {
        self.collectionView.isHidden = true
        self.errorView.isHidden = true
    }
    
    func configureErrorState(message: String = "Something went wrong", retryHandler: @escaping () -> Void) {
        self.content = []
        self.errorLabel.text = message
        self.retryButton.removeTarget(nil, action: nil, for: .allEvents)
        self.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        self.retryHandler = retryHandler
        
        self.errorView.isHidden = false
        self.collectionView.isHidden = true
    }
    
    private var retryHandler: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        retryHandler?()
    }
}

extension HomeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: content[indexPath.row].posterPath)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentSize.width - scrollView.contentOffset.x < scrollView.frame.width {
//            print(scrollView.contentOffset)
//        }
//        
    }
}
