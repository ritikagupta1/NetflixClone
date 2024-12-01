//
//  SearchResultsViewModel.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 28/11/24.
//

import Foundation
class SearchResultsViewModel {
    private(set) var searchResults: [Content] = []
    private(set) var page = 1
    
    var isLoadingSearchResults: Bool = true
    var hasMoreSearchResults: Bool = true
    
    func numberOfItems() -> Int {
        searchResults.count
    }
    
    func getPosterPath(for index: Int) -> String? {
        searchResults[index].posterPath
    }
    
    func resetSearchResults() {
        isLoadingSearchResults = false
        hasMoreSearchResults = false
        searchResults.removeAll()
        page = 1
    }
    
    func updateResults(with content: ContentInfo) {
        isLoadingSearchResults = false
        hasMoreSearchResults = content.page < content.totalPages && !content.results.isEmpty
        page += 1
        searchResults.append(contentsOf: content.results)
    }
    
    func shouldLoadMoreContent() -> Bool {
        !isLoadingSearchResults && hasMoreSearchResults
    }
}
