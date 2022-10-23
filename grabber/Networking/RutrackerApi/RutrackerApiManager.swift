//
//  RutrackerApiManager.swift
//  grabber
//
//  Created by Станислав К. on 13.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation

class RutrackerApiManager {
    private let apiService: ApiServiceImpl
    private let htmlParser: Rutracker_org_HtmlParser
    
    init(
        apiService: ApiServiceImpl = ApiServiceFactory.rutracker(),
        htmlParser: Rutracker_org_HtmlParser = Rutracker_org_HtmlParser()
    ) {
        self.apiService = apiService
        self.htmlParser = htmlParser
    }
    
    func login(login: String, password: String, completion: @escaping () -> ()) {
        let token = ApiServiceToken(
            path: "/login.php",
            parameters: [
                "login_username": "malkozoz",
                "login_password": "canoni250",
                "login": "Вход"
            ],
            method: .post
        )
        apiService.makeRequest(token: token) { result in
            completion()
        }
    }
    
    func getTrackers(searchText: String, parameters: RutrackerSearchParameters, completion: @escaping (Result<[TorrentPreviewModel], Error>) -> Void) {
        let token = ApiServiceToken(
            path: "/tracker.php",
            queryItems: ["nm" : searchText],
            parameters: parameters.toDic(),
            method: .post
        )
        
        apiService.makeRequest(token: token, completion: { [htmlParser] result in
            do {
                let html = try unwrapString(result: result)
                let trackers = htmlParser.trackers(html: html)
                completion(.success(trackers))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    func getTrackerInfo(id: String, completion: @escaping (Result<TorrentDetailModel, Error>) -> Void) {
        let token = ApiServiceToken(
            path: "/viewtopic.php",
            queryItems: ["t" : id],
            method: .post
        )
        apiService.makeRequest(token: token, completion: { [htmlParser] result in
            do {
                let html = try unwrapString(result: result)
                let tracker = try htmlParser.trackerDetail(html: html)
                completion(.success(tracker))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    func getTorrentFile(topicId: String, completion: @escaping (Swift.Result<Data, Error>) -> Void) {
        let token = ApiServiceToken(
            path: "/dl.php",
            queryItems: ["t" : topicId],
            method: .post
        )
        apiService.makeRequest(token: token, completion: { result in
            do {
                let data: Data = try result.get()
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        })
    }
    
    
        /*
         favorites -> https://rutracker.org/forum/bookmarks.php
         addToFavorites -> ...
         
         
         */
    
    
}

fileprivate func unwrapString(result: Result<Data, Error>) throws -> String {
    let data = try result.get()
    guard let str = String(data: data, encoding: .windowsCP1251) else {
        throw NSError()
    }
    return str
}




