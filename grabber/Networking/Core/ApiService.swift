//
//  ClientBaseProtocol.swift
//  Betterme
//
//  Created by Iaroslav Morozov on 12/20/16.
//  Copyright © 2016 Iaroslav Morozov. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class ApiServiceImpl {
    private let session: URLSession
    private let baseUrl: URL
    private let defaultHeaders: [String : String]
    
    init(
        session: URLSession,
        baseUrl: URL,
        defaultHeaders: [String : String]
    ) {
        self.session = session
        self.baseUrl = baseUrl
        self.defaultHeaders = defaultHeaders
    }
    
    @discardableResult
    func makeRequest(token: ApiServiceToken, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask? {
        do {
            let req = try buildUrlRequest(token: token)
            let task = session.dataTask(with: req) { (data, response, error) in
                guard
                    let data = data,
                    error == nil
                else {
                    completion(.failure(error ?? ApiServiceError.noData))
                    return
                }
                completion(.success(data))
            }
            task.resume()
            return task
            
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    // MARK: - Private
    private func buildUrlRequest(token: ApiServiceToken) throws -> URLRequest {
        var components = URLComponents(url: baseUrl.appendingPathComponent(token.path), resolvingAgainstBaseURL: true)
        //components?.queryItems = token.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        ///
        let parameterItems: [URLQueryItem] = token.parameters.compactMap {
            if let val = $0.value as? [String] {
                return URLQueryItem(name: $0.key, value: val.joined(separator: ","))
            }
            guard let val = $0.value as? String else { return nil }
            return URLQueryItem(name: $0.key, value: val)
        }
        let queryItems = token.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        components?.queryItems = parameterItems + queryItems
        
        
        ///
        guard let url = components?.url else {
            throw ApiServiceError.badUrl
        }
        
        let mergedHeaders = defaultHeaders.merging(token.headers, uniquingKeysWith: { (first, _) in first })
 
        var req = URLRequest(url: url)
        req.httpMethod = token.method.rawValue
        req.headers = .init(mergedHeaders)
//        let parameters = token.parameters
        
        do {
            req.httpBody = components?.query?.data(using: .utf8) //try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            throw error
        }
        
        return req
    }
}

class ApiServiceFactory {
    static func rutracker(
        session: URLSession = URLSession(configuration: urlSessionConfiguration())
    ) -> ApiServiceImpl {
        return ApiServiceImpl(
            session: session,
            baseUrl: URL(string: "https://rutracker.org/forum")!,
            defaultHeaders: [
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "User-Agent": "Safari/604.1",
            ]
        )
    }
    
    private static func urlSessionConfiguration() -> URLSessionConfiguration {
        let cache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = cache
        return config
    }
}
