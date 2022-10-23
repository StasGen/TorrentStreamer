//
//  ApiServiceToken.swift
//  grabber
//
//  Created by Stanislav Kaliberov on 16.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

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
