//
//  TopSearchViewModel.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 28/11/24.
//

import Foundation
class TopSearchViewModel {
    var topSearchMovies: [Content] = []
    var isLoadingMovies: Bool = false
    var hasMoreMovies: Bool = true
    var page: Int = 1
    
    
    let contentRepository: ContentFetcher
    
    init(contentRepository: ContentFetcher = ContentRepository()) {
        self.contentRepository = contentRepository
    }
    
    func getTopSearchMovies(completion: @escaping (Bool) -> Void) {
        guard !isLoadingMovies, hasMoreMovies else {
            completion(false)
            return
        }
        
        self.isLoadingMovies = true
        
        contentRepository.discoverMovies(page: page) { [weak self] result in
            self?.isLoadingMovies = false
            guard let self = self else {
                completion(false)
                return
            }
            
            switch result {
            case .success(let content):
                DispatchQueue.main.async {
                    self.topSearchMovies.append(contentsOf: content.results)
                    self.hasMoreMovies = content.page < content.totalPages
                    self.page += 1
                    completion(true)
                }
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func shouldLoadMore() -> Bool {
        !isLoadingMovies && hasMoreMovies
    }
    
    func getNumberOfRows() -> Int {
        topSearchMovies.count
    }
    
    func getContent(for index: Int) -> Content {
        topSearchMovies[index]
    }
}
