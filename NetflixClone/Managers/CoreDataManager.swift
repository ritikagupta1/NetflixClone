//
//  CoreDataManager.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/12/24.
//

import CoreData
import UIKit
enum CoreDataError: Error {
    case fetchFailed
    case savingFailed
    case deletionFailed
}

final class CoreDataManager {
    static let shared = CoreDataManager()
    let context = ((UIApplication.shared.delegate) as? AppDelegate)?.persistentContainer.viewContext
    
    private init() {}
    
    func getDownloadedContent(completion: @escaping(Result<[DownloadedContent], CoreDataError>) -> Void) {
        guard let context = context else {
            completion(.failure(.fetchFailed))
            return
        }
        
        let fetchRequest = DownloadedContent.fetchRequest()
        do {
            let downloadedItems = try context.fetch(fetchRequest)
            completion(.success(downloadedItems))
        } catch {
            completion(.failure(.fetchFailed))
        }
    }
    
    func addDownloadedContent(content: Content, completion: @escaping(Result<Void, CoreDataError>) -> Void) {
        guard let context = context else {
            completion(.failure(.savingFailed))
            return
        }
        
        let downloadContent = DownloadedContent(context: context)
        downloadContent.configure(with: content)
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(.savingFailed))
        }
    }
    
    func deleteDownloadedContent(content: DownloadedContent, completion: @escaping(Result<Void, CoreDataError>) -> Void) {
        guard let context = context else {
            completion(.failure(.savingFailed))
            return
        }
        
        context.delete(content)
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(.deletionFailed))
        }
    }
}

extension DownloadedContent {
    func configure(with content: Content) {
        id = Int64(content.id)
        originalName = content.originalName
        originalTitle = content.originalTitle
        posterPath = content.posterPath
        overview = content.overview
        voteCount = content.voteCount.map(Int64.init) ?? 0
        voteAverage = content.voteAverage ?? 0.0
        mediaType = content.mediaType
        releaseDate = content.releaseDate
    }
}
