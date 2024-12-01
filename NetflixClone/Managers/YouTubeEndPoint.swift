//
//  YouTubeEndPoint.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 29/11/24.
//

import Foundation
struct YouTubeEndPoint: EndPoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension YouTubeEndPoint {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "youtube.googleapis.com"
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}

extension YouTubeEndPoint {
    static var apiKey: String? {
        Bundle.main.infoDictionary?["YT_API_KEY"] as? String
    }
    
    static func getMovies(query: String) -> YouTubeEndPoint {
        return YouTubeEndPoint(
            path: "/youtube/v3/search",
            queryItems: [URLQueryItem(name: "key" , value: apiKey),
                         URLQueryItem(name: "q" , value: query)])
    }
}
