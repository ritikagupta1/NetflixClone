//
//  NetworkManager.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 26/10/24.
//

import Foundation
enum NetflixError: String, Error {
    case unableToCompleteRequest = "Unable to complete your request, Please Check your Internet Connection."
    case invalidResponse = "Invalid Response from server,Please try again."
    case invalidData = "The data received from the server was invalid.Please try again."
}

final class NetworkManager {
    private init() {}
    
    static let shared = NetworkManager()
    
    func getTrendingMovies(completion: @escaping(Result<[Content], NetflixError>) -> Void) {
        let endpoint = EndPoint.trendingMovies()
        getData(endPoint: endpoint){ (result: Result<TrendingContent, NetflixError>) in
            switch result {
            case .success(let result):
                completion(.success(result.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTrendingTv(completion: @escaping (Result<[Content], NetflixError>) -> Void) {
        let endPoint = EndPoint.trendingTV()
        getData(endPoint: endPoint) { (result: Result<TrendingContent, NetflixError>) in
            switch result {
            case .success(let result):
                completion(.success(result.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getUpcomingMovies(completion: @escaping (Result<[Content], NetflixError>) -> Void) {
        let endPoint = EndPoint.upcomingMovies()
        getData(endPoint: endPoint) { (result: Result<TrendingContent, NetflixError>) in
            switch result {
            case .success(let result):
                completion(.success(result.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPopularMovies(completion: @escaping (Result<[Content], NetflixError>) -> Void) {
        let endPoint = EndPoint.popularMovies()
        getData(endPoint: endPoint) { (result: Result<TrendingContent, NetflixError>) in
            switch result {
            case .success(let result):
                completion(.success(result.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTopRatedMovies(completion: @escaping (Result<[Content], NetflixError>) -> Void) {
        let endPoint = EndPoint.topRated()
        getData(endPoint: endPoint) { (result: Result<TrendingContent, NetflixError>) in
            switch result {
            case .success(let result):
                completion(.success(result.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getData<T: Codable>(endPoint: EndPoint, completion: @escaping (Result<T, NetflixError>) -> Void) {
        guard let url = endPoint.url else {
            completion(.failure(.unableToCompleteRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.unableToCompleteRequest))
                return
            }
            
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Check if data exists
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            //Decode the data
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.invalidData))
            }
            
        }
        
        task.resume()
    }
}
