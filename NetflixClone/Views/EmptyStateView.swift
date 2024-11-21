//
//  EmptyStateView.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 19/11/24.
//

import UIKit

class EmptyStateView: UIView {
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .popcorn
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .gray
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Content Available"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Looks like everyone's taking a break!\nClick to refresh or try again later 🎬"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = .label
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    var onRefresh: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to stack
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(refreshButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 250),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            refreshButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        onRefresh?()
    }
}
