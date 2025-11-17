//
//  TorrentDetailViewModel.swift
//  grabber
//
//  Created by Stanislav Kaliberov on 24.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation
import PopcornTorrent
import MobileVLCKit
import Combine

class TorrentDetailViewModel {
    indirect enum State {
        case initial
        case fetchTrackerInfo
        case readyForStream(TorrentDetailModel)
        case downloadTorrentFile
        case startStream(URL)
        case needToSelectFileIndex([String])
        case streamingAndShowPlayer(videoFileURL: URL)
        case failed(State, Error)
    }
    
    init(
        id: String,
        torrentFileUrl: URL? = nil,
        info: TorrentDetailModel? = nil,
        fileIndexForPlay: Int? = nil
    ) {
        self.id = id
        self.torrentFileUrl = torrentFileUrl
        self.info = info
        self.fileIndexForPlay = fileIndexForPlay
    }
    
    private var id: String
    private var torrentFileUrl: URL?
    private var info: TorrentDetailModel?
    private var fileIndexForPlay: Int?
    
    @Published var state: State = .initial {
        didSet {
            switch state {
            case .initial:
                break
                
            case .fetchTrackerInfo:
                fetchTrackerInfo()
                
            case .readyForStream(let detailModel):
                info = detailModel
                streamer.cancelStreamingAndDeleteData(true)
                
            case .downloadTorrentFile:
                fetchFile()
                
            case .startStream(let url):
                torrentFileUrl = url
                play(fileUrl: url)
                
            case .needToSelectFileIndex:
                break
                
            case .streamingAndShowPlayer:
                break
                
            case .failed:
                break
            }
        }
    }
    
    private let api: RutrackerApiManager = RutrackerApiManager()
    private let streamer: PTTorrentStreamer = PTTorrentStreamer.shared()
    
    deinit {
        streamer.cancelStreamingAndDeleteData(true)
    }
    
    // MARK: - Interface
    func viewDidLoad() {
        print("Open tracker - ", id)
        state = .fetchTrackerInfo
    }
    
    func playButtonDidTap() {
        if case .readyForStream = state {
            state = .downloadTorrentFile
        } else if case .failed = state {
            state = .fetchTrackerInfo
        }
    }
    
    func selectTorrentFile(index: Int) {
        fileIndexForPlay = index
        if let torrentFileUrl = self.torrentFileUrl {
            self.state = .startStream(torrentFileUrl)
        } else {
            self.state = .downloadTorrentFile
        }
    }
    
    func returnToReadyForStream() {
        guard let info = info else {
            state = .fetchTrackerInfo
            return
        }
        state = .readyForStream(info)
    }
    
    
    // MARK: - Privates
    private func fetchTrackerInfo() {
        api.getTrackerInfo(id: id) { [weak self] result in
            guard let self = self else { return }
            do {
                self.state = .readyForStream(try result.get())
            } catch {
                self.state = .failed(self.state, error)
            }
        }
    }
    
    private func fetchFile() {
        api.getTorrentFile(topicId: id) { [weak self] result in
            guard let self = self else { return }
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = documentDirectory.appendingPathComponent(self.id)
                let torrentFile = try result.get()
                try torrentFile.write(to: fileURL)
                self.state = .startStream(fileURL)
                
            } catch {
                self.state = .failed(self.state, error)
            }
        }
    }
    
    private func play(fileUrl: URL) {
        streamer.startStreaming(
            fromMultiTorrentFileOrMagnetLink: fileUrl.path,
            progress: { (status) in
                print(status)
            },
            readyToPlay: { [weak self] (videoFileURL, videoFilePath) in
                if case .needToSelectFileIndex = self?.state {
                    self?.streamer.cancelStreamingAndDeleteData(true)
                } else {
                    self?.state = .streamingAndShowPlayer(videoFileURL: videoFileURL)
                }
            },
            failure: { [weak self] error in
                guard let self = self else { return }
                self.state = .failed(self.state, error)
                
            }
        ) { [weak self] result in
            guard let self = self else { return 0 }
            print(result)
            
            if result.count == 1 {
                self.fileIndexForPlay = 0
                return 0
                
            } else if let fileIndex = self.fileIndexForPlay {
                return Int32(fileIndex)
                
            } else {
                self.state = .needToSelectFileIndex(result)
                return 0
            }
        }
    }
}
