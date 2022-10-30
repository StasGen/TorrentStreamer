//
//  TorrentPreviewModel.swift
//  grabber
//
//  Created by Станислав К. on 13.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation

struct TorrentPreviewModel {
    let id: String
    let name: String
    let kByte: Double
    let tags: [String]
    let createdDate: Date?
    let liveParams: TorrentLiveParams
    
}

struct TorrentLiveParams {
    let seeds: Int
    let downloads: Int
    let peers: Int
}

