//
//  TorrentDetailViewController.swift
//  grabber
//
//  Created by Станислав Калиберов on 10.02.2018.
//  Copyright © 2018 Станислав Калиберов. All rights reserved.
//

import UIKit
import PopcornTorrent
import MobileVLCKit

class TorrentDetailViewController: UIViewController {
    @IBOutlet weak var bobodyTextViewdyLabel: UITextView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var videoControlButton: UIButton!
    
    var id: String!
    var torrentFileUrl: URL?
    
    private let api: RutrackerApiManager = RutrackerApiManager()
    private let streamer: PTTorrentStreamer = PTTorrentStreamer.shared()
    private let mediaplayer = VLCMediaPlayer()
    
    
    func updateUI(info: TorrentDetailModel) {
        info.image.flatMap { ImageViewDownloader().perform(from: $0, imageView: backgroundImageView)}
        title = info.name
        bobodyTextViewdyLabel.text = info.body
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Open tracker - ", id)
        
        api.getTrackerInfo(id: id) { [weak self] result in
            do {
                let info = try result.get()
                self?.updateUI(info: info)
                
            } catch {
                
            }
        }
        
        func fetchFile() {
            api.getTorrentFile(topicId: id) { [weak self] result in
                guard let strongSelf = self else { return }
//                DispatchQueue.main.async {
                    do {
                        let fileManager = FileManager.default
                        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        let fileURL = documentDirectory.appendingPathComponent(strongSelf.id)
                        let torrentFile = try result.get()
                        try torrentFile.write(to: fileURL)
                        strongSelf.torrentFileUrl = fileURL
                        
                        strongSelf.didTapVideoControlButton(UIButton())
                        
                    } catch {
                        print(error)
                    }
//                }
            }
        }
        
        fetchFile()
        mediaplayer.delegate = self
    }
    
    
    
    
    func play(fileUrl: URL) {
        streamer.startStreaming(
            fromMultiTorrentFileOrMagnetLink: fileUrl.path,
            progress: { (status) in
                print(status)
            },
            readyToPlay: { [weak self] (videoFileURL, videoFilePath) in
                print(videoFileURL)
                print(videoFilePath)
            },
            failure: { error in
                print(error)
            }) { result in
                print(result)

                return 0
            }
        
        
//        streamer.startStreaming(
//            fromFileOrMagnetLink: fileUrl.path,
//            progress: { (status) in
//                print(status)
//            },
//            readyToPlay: { [weak self] (videoFileURL, videoFilePath) in
//                print(videoFileURL)
//                print(videoFilePath)
//
//                DispatchQueue.main.async {
//                    guard let self = self else { return }
//                    self.mediaplayer.drawable = self.playerView
//                    self.mediaplayer.media = VLCMedia(url: videoFileURL)
//                    self.mediaplayer.play()
//                }
//
//            }) { (error) in
//                print(error)
//            }
    }
    
    @IBAction func didTapVideoControlButton(_ sender: UIButton) {
        guard let url = torrentFileUrl else { return }
        play(fileUrl: url)
    }
    
}

extension TorrentDetailViewController: VLCMediaPlayerDelegate {
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print("mediaPlayerStateChanged")
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        print("mediaPlayerTimeChanged")
        aNotification.debugDescription
    }
    
    func mediaPlayerTitleChanged(_ aNotification: Notification!) {
        print("mediaPlayerTitleChanged")
    }
    
    func mediaPlayerChapterChanged(_ aNotification: Notification!) {
        print("mediaPlayerChapterChanged")
    }
}





