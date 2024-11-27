//
//  ComingSoonViewModel.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 27/11/24.
//

import Foundation
class ComingSoonViewModel {
    var upcomingMovies: [Content] = []
    var isLoadingMovies: Bool = false
    var hasMoreMovies: Bool = true
    var page: Int = 1
    
    let contentRepository: ContentFetcher
    
    init(contentRepository: ContentFetcher = ContentRepository()) {
        self.contentRepository = contentRepository
    }
    
    func getUpcomingMovies(completion: @escaping (Bool) -> Void) {
        guard !isLoadingMovies, hasMoreMovies else {
            completion(false)
            return
        }
        
        self.isLoadingMovies = true
        
        contentRepository.fetchContent(for: .upcomingMovies, page: page) { [weak self] result in
            guard let self = self else {
                completion(false)
                return
            }
            
            self.isLoadingMovies = false
            
            switch result {
            case .success(let contentResponse):
                self.upcomingMovies.append(contentsOf: contentResponse.results)
                self.hasMoreMovies = contentResponse.page < contentResponse.totalPages
                self.page += 1
                completion(true)
                
            case .failure:
                completion(false)
            }
        }
    }
    
    func shouldLoadMore() -> Bool {
        return  hasMoreMovies && !isLoadingMovies
    }
}
