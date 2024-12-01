//
//  EndPoint.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/10/24.
//

import Foundation
protocol EndPoint {
    var path: String {get}
    var queryItems: [URLQueryItem] {get}
    var url: URL? {get}
}
struct TMDBEndPoint: EndPoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension TMDBEndPoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}

extension TMDBEndPoint {
    static var apiKey: String? {
        Bundle.main.infoDictionary?["API_KEY"] as? String
    }
    
    static func trendingMovies(page: Int) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/trending/movie/day",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "page" , value: "\(page)")])
    }
    
    static func trendingTV(page: Int) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/trending/tv/day",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "page" , value: "\(page)")])
    }
    
    static func upcomingMovies(page: Int) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/movie/upcoming",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "language", value: "en-US"),
                         URLQueryItem(name: "page" , value: "\(page)")])
    }
    
    static func popularMovies(page: Int) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/movie/popular",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "language", value: "en-US"),
                         URLQueryItem(name: "page" , value: "\(page)")])
    }
    
    static func topRated(page: Int) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/movie/top_rated",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "language", value: "en-US"),
                         URLQueryItem(name: "page" , value: "\(page)")])
    }
    
    static func discoverMovies(page: Int) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/discover/movie",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "page" , value: "\(page)")])
    }
    
    static func searchMovies(page: Int, query: String) -> TMDBEndPoint {
        return TMDBEndPoint(
            path: "/3/search/movie",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "page" , value: "\(page)"),
                         URLQueryItem(name: "query", value: query)])
    }
}
