//
//  Trailer.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 29/11/24.
//

import Foundation
struct TrailerResponse: Codable {
    let items: [Trailer]
}

struct Trailer: Codable {
    let id: TrailerID
}

struct TrailerID: Codable {
    let kind: String
    let videoId: String?
}
