//
//  SearchResultsVC.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/11/24.
//

import UIKit

class SearchResultsVC: NetflixDataLoadingVC {
    var viewModel: SearchResultsViewModel
    
    var searchCollectionView: UICollectionView!
    var getMoreResults: ((Int) -> Void)?
    var didSelectContent: ((Content) -> Void)?
    
    init(viewModel: SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
    }
    
    func createFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let totalWidth = view.bounds.width
        let padding: CGFloat = 10
        let minimumSpacing: CGFloat = 8
        
        let availableWidth = totalWidth - (2 * padding) - (2 * minimumSpacing)
        let itemWidth = availableWidth / 3
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.minimumInteritemSpacing = minimumSpacing
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        return flowLayout
    }
    
    func configureCollectionView() {
        searchCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createFlowLayout())
        view.addSubview(searchCollectionView)
        searchCollectionView.frame = view.bounds
        searchCollectionView.backgroundColor = .systemBackground
        searchCollectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
}

extension SearchResultsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModel.getPosterPath(for: indexPath.row))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchCollectionView.deselectItem(at: indexPath, animated: true)
        let content = self.viewModel.searchResults[indexPath.row]
        self.didSelectContent?(content)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.bounds.height, viewModel.shouldLoadMoreContent() {
            self.showLoadingView()
            self.viewModel.isLoadingSearchResults = true
            self.getMoreResults?(viewModel.page)
        }
    }
}
