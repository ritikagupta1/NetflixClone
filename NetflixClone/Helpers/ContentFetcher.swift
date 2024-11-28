//
//  ContentFetcher.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 27/11/24.
//

import Foundation
protocol ContentFetcher {
    func fetchContent(
        for section: Sections,
        page: Int,
        completion: @escaping (Result<ContentInfo, NetflixError>) -> Void
    )
    
    func discoverMovies(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void)
}

class ContentRepository: ContentFetcher{
    func fetchContent(
        for section: Sections,
        page: Int,
        completion: @escaping (Result<ContentInfo, NetflixError>) -> Void
    ) {
        switch section {
        case .trendingMovies:
            NetworkManager.shared.getTrendingMovies(page: page, completion: completion)
        case .trendingTv:
            NetworkManager.shared.getTrendingTv(page: page, completion: completion)
        case .popular:
            NetworkManager.shared.getUpcomingMovies(page: page, completion: completion)
        case .upcomingMovies:
            NetworkManager.shared.getUpcomingMovies(page: page, completion: completion)
        case .topRated:
            NetworkManager.shared.getTopRatedMovies(page: page, completion: completion)
        }
    }
    
    func discoverMovies(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        NetworkManager.shared.discoverMovies(page: page, completion: completion)
    }
    
}
