//
//  DownloadsVC.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/10/24.
//

import UIKit

class DownloadsVC: NetflixDataLoadingVC {
    var viewModel: DownloadViewModel
    let rowHeight: CGFloat = 160
    
    init(viewModel: DownloadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let downloadTableView: UITableView = {
        let tableview = UITableView()
        tableview.backgroundColor = .systemBackground
        tableview.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()
        self.configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getDownloadedMovies()
    }
    
    private func configureViewController() {
        self.view.backgroundColor = .yellow
        self.title = Constants.downloadScreenTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func configureTableView() {
        self.view.addSubview(downloadTableView)
        downloadTableView.translatesAutoresizingMaskIntoConstraints = false
        self.downloadTableView.delegate = self
        self.downloadTableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadTableView.frame = view.bounds
    }
    
    private func getDownloadedMovies() {
        self.showLoadingView()
        
        self.viewModel.getDownloadedMovies { [weak self] success in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Ensures the animation is visible
                self.dismissLoadingIndicator()
                if success {
                    self.downloadTableView.reloadData()
                }
            }
        }
    }
}

extension DownloadsVC: UITableViewDelegate, UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.downloadTableView.deselectRow(at: indexPath, animated: true)
        let content = self.viewModel.downloadedMovies[indexPath.row]
        let model = ContentPreviewModel(contentTitle: content.originalTitle ?? content.originalName ?? "Unknown", contentOverView: content.overview ?? "Unknown")
        let contentPreviewVC = ContentPreviewViewController()
        contentPreviewVC.configure(with: model)
        self.navigationController?.pushViewController(contentPreviewVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            CoreDataManager.shared.deleteDownloadedContent(content: self.viewModel.downloadedMovies[indexPath.row]) { result in
                switch result {
                case .success:
                    self.viewModel.downloadedMovies.remove(at: indexPath.row)
                    self.downloadTableView.deleteRows(at: [indexPath], with: .fade)
                case .failure:
                    print("Deletion Failed")
                }
            }
        
        default:
            break
        }
    }
}
