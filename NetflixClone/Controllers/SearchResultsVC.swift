//
//  SearchResultsVC.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/11/24.
//

import UIKit

class SearchResultsVC: NetflixDataLoadingVC {
    var searchCollectionView: UICollectionView!
    
    var searchResults: [Content] = []
    var page = 1
    var getMoreResults: ((Int) -> Void)?
    
    var isLoadingSearchResults: Bool = true
    var hasMoreSearchResults: Bool = true
    
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
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: searchResults[indexPath.row].posterPath)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height - scrollView.contentOffset.y < scrollView.bounds.height, !isLoadingSearchResults, hasMoreSearchResults {
            self.showLoadingView()
            self.page += 1
            self.isLoadingSearchResults = true
            self.getMoreResults?(page)
        }
    }
}
