//
//  Sections.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 19/11/24.
//

import Foundation

enum Sections: Int, CaseIterable {
    case trendingMovies
    case trendingTv
    case popular
    case upcomingMovies
    case topRated
    
    var title: String {
        switch self {
        case .trendingMovies:
            return "Trending Movies"
        case .trendingTv:
            return "Trending TV"
        case .popular:
            return "Popular"
        case .upcomingMovies:
            return "Upcoming Movies"
        case .topRated:
            return "Top Rated"
        }
    }
}
