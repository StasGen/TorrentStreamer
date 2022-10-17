//
//  ApiServiceError.swift
//  grabber
//
//  Created by Stanislav Kaliberov on 16.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation

enum ApiServiceError: Error {
    case badUrl
    case noData
}
