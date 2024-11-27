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
    
    func getTrendingMovies(page: Int, completion: @escaping(Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.trendingMovies(page: page)
        getData(endPoint: endPoint, completion: completion)
    }
    
    func getTrendingTv(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.trendingTV(page: page)
        getData(endPoint: endPoint, completion: completion)
    }
    
    func getUpcomingMovies(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.upcomingMovies(page: page)
        getData(endPoint: endPoint, completion: completion)
    }
    
    func getPopularMovies(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.popularMovies(page: page)
        getData(endPoint: endPoint, completion: completion)
    }
    
    func getTopRatedMovies(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.topRated(page: page)
        getData(endPoint: endPoint, completion: completion)
    }
    
    func discoverMovies(page: Int, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.discoverMovies(page: page)
        getData(endPoint: endPoint, completion: completion)
    }
    
    func searchMovies(page: Int, query: String, completion: @escaping (Result<ContentInfo, NetflixError>) -> Void) {
        let endPoint = EndPoint.searchMovies(page: page, query: query)
        getData(endPoint: endPoint, completion: completion)
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
                sleep(3)
                completion(.success(result))
            } catch {
                completion(.failure(.invalidData))
            }
            
        }
        
        task.resume()
    }
}
