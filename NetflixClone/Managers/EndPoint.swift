//
//  EndPoint.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/10/24.
//

import Foundation
struct EndPoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension EndPoint {
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

extension EndPoint {
    static var apiKey: String? {
        Bundle.main.infoDictionary?["API_KEY"] as? String
    }
    
    static func trendingMovies() -> EndPoint {
        return EndPoint(
            path: "/3/trending/movie/day",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey)])
    }
    
    static func trendingTV() -> EndPoint {
        return EndPoint(
            path: "/3/trending/tv/day",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey)])
    }
    
    static func upcomingMovies() -> EndPoint {
        return EndPoint(
            path: "/3/movie/upcoming",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "language", value: "en-US"),
                          URLQueryItem(name: "page", value: "1")])
    }
    
    static func popularMovies() -> EndPoint {
        return EndPoint(
            path: "/3/movie/popular",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "language", value: "en-US"),
                          URLQueryItem(name: "page", value: "1")])
    }
    
    static func topRated() -> EndPoint {
        return EndPoint(
            path: "/3/movie/top_rated",
            queryItems: [URLQueryItem(name: "api_key" , value: apiKey),
                         URLQueryItem(name: "language", value: "en-US"),
                          URLQueryItem(name: "page", value: "1")])
    }
}
