//
//  DownloadViewModel.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/12/24.
//
import Foundation

class DownloadViewModel {
    var downloadedMovies: [DownloadedContent] = []
    
    func getDownloadedMovies(completion: @escaping (Bool) -> Void) {
        CoreDataManager.shared.getDownloadedContent { result in
            switch result {
            case .success(let downloadedMovies):
                self.downloadedMovies = downloadedMovies
                completion(true)
            case .failure :
                completion(false)
            }
        }
    }
    
    func getNumberOfRows() -> Int {
        downloadedMovies.count
    }
    
    func getContent(for index: Int) -> Content {
        Content(from: downloadedMovies[index])
    }
}
