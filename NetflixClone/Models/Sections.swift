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
            return Constants.trendingMoviesTitle
        case .trendingTv:
            return Constants.trendingTvTitle
        case .popular:
            return Constants.popularMoviesTitle
        case .upcomingMovies:
            return Constants.upcomingMoviesTitle
        case .topRated:
            return Constants.topRatedTitle
        }
    }
}
