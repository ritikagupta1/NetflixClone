//
//  Movie.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 17/11/24.
//

import Foundation
struct TrendingContent: Codable {
    let results: [Content]
}
struct Content: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case originalName = "original_name"
        case originalTitle = "original_title"
        case overview = "overview"
        case posterPath = "poster_path"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
        case releaseDate = "release_date"
    }
    let id: Int
    let originalName: String?
    let originalTitle: String?
    let posterPath: String
    let overview: String?
    let voteCount: Int
    let voteAverage: Double
    let mediaType: String?
    let releaseDate: String?
}