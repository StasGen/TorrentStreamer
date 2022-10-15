//
//  ClientBaseProtocol.swift
//  Betterme
//
//  Created by Iaroslav Morozov on 12/20/16.
//  Copyright © 2016 Iaroslav Morozov. All rights reserved.
//

import Alamofire
import Foundation

struct ApiServiceToken {
    let path: String
    let queryItems: [String: String]
    let parameters: [String : Any]
    let headers: [String : String]
    let method: HTTPMethod
    
    init(
        path: String,
        queryItems: [String : String] = [:],
        parameters: [String : Any] = [:],
        headers: [String : String] = [:],
        method: HTTPMethod = .get
    ) {
        self.path = path
        self.queryItems = queryItems
        self.parameters = parameters
        self.headers = headers
        self.method = method
    }
}

enum ApiServiceError: Error {
    case badUrl
}

class ApiServiceImpl {
    private let sessionManager: SessionManager
    private let baseUrl: URL
    private let defaultHeaders: [String : String]
    
    init(
        sessionManager: SessionManager,
        baseUrl: URL,
        defaultHeaders: [String : String]
    ) {
        self.sessionManager = sessionManager
        self.baseUrl = baseUrl
        self.defaultHeaders = defaultHeaders
    }
    
    @discardableResult
    func makeStringRequest(token: ApiServiceToken, completion: @escaping (Result<String>) -> Void) -> Request? {
        do {
            let request = try makeRequest(token: token)
            return request.responseString { response in
                completion(response.result)
            }
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    @discardableResult
    func makeDataRequest(token: ApiServiceToken, completion: @escaping (Result<Data>) -> Void) -> Request? {
        do {
            let request = try makeRequest(token: token)
            return request.responseData { response in
                completion(response.result)
            }
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    // MARK: - Private
    private func makeRequest(token: ApiServiceToken) throws -> DataRequest {
        var components = URLComponents(url: baseUrl.appendingPathComponent(token.path), resolvingAgainstBaseURL: true)
        components?.queryItems = token.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else {
            throw ApiServiceError.badUrl
        }
        
        let mergedHeaders = defaultHeaders.merging(token.headers, uniquingKeysWith: { (first, _) in first })
        
        return sessionManager.request(
            url,
            method: token.method,
            parameters: token.parameters,
            encoding: URLEncoding.httpBody,
            headers: mergedHeaders
        )
    }
}

private extension ApiServiceImpl {
    private func checkNeedLogin() {
//    https://rutracker.org/forum/tracker.php
    }
    
    
    private func saveCookies(response: HTTPURLResponse) {
//        let headerFields = response.allHeaderFields as! [String: String]
//        let url = response.url
        let cookies = HTTPCookieStorage.shared.cookies(for: response.url!) //HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
//        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies! {
//            cookieArray.append(cookie.properties!)
            sessionManager.session.configuration.httpCookieStorage?.setCookie(cookie)
        }
        
//        UserDefaults.standard.set(cookieArray, forKey: "savedCookies")
//        UserDefaults.standard.synchronize()
    }
    
//    private func loadCookies() {
//        guard let cookieArray = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] else { return }
//        for cookieProperties in cookieArray {
//            if let cookie = HTTPCookie(properties: cookieProperties) {
//                HTTPCookieStorage.shared.setCookie(cookie)
//            }
//        }
//    }
}






class ApiServiceFactory {
    static func rutracker(
        sessionManager: SessionManager = ApiServiceFactory.sessionManager()
    ) -> ApiServiceImpl {
        return ApiServiceImpl(
            sessionManager: sessionManager,
            baseUrl: URL(string: "https://rutracker.org/forum")!,
            defaultHeaders: [
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "User-Agent": "Safari/604.1",
            ]
        )
    }
    
    private static func sessionManager() -> SessionManager {
        let cache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = cache
        return SessionManager(configuration: config)
    }
}
