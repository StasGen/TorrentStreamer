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
    indirect enum State {
        case initial
        case fetchTrackerInfo
        case readyForStream
        case downloadTorrentFile
        case startStream(URL)
        case failed(State, Error)
    }
    
    @IBOutlet weak var bobodyTextViewdyLabel: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var videoControlButton: UIButton!
    
    var id: String!
    var torrentFileUrl: URL?
    var info: TorrentDetailModel?
    
    private let api: RutrackerApiManager = RutrackerApiManager()
    private let streamer: PTTorrentStreamer = PTTorrentStreamer.shared()
    private var state: State = .initial {
        didSet {
            print("current state = ", state)
            DispatchQueue.main.async {
                switch self.state {
                case .initial: break
                    
                case .fetchTrackerInfo:
                    self.activityIndicatorView.startAnimating()
                    self.activityIndicatorView.isHidden = false
                    self.fetchTrackerInfo()
                    
                case .readyForStream:
                    self.streamer.cancelStreamingAndDeleteData(true)
                    self.updateUI()
                    self.activityIndicatorView.isHidden = true
                    
                case .downloadTorrentFile:
                    self.activityIndicatorView.isHidden = false
                    self.fetchFile()
                    
                case .startStream(let url):
                    self.play(fileUrl: url)
                
                case .failed(let oldState, let error):
                    print(oldState, error)
                    self.activityIndicatorView.isHidden = true
                }
            }
        }
    }
    
    deinit {
        streamer.cancelStreamingAndDeleteData(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Open tracker - ", id!)
        state = .fetchTrackerInfo
    }
    
    private func updateUI() {
        info?.image.flatMap { ImageViewDownloader().perform(from: $0, imageView: backgroundImageView)}
        title = info?.name ?? "None"
        bobodyTextViewdyLabel.text = info?.body ?? "None"
    }
    
    private func fetchTrackerInfo() {
        api.getTrackerInfo(id: id) { [weak self] result in
            guard let self = self else { return }
            do {
                self.info = try result.get()
                self.state = .readyForStream
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
                self.torrentFileUrl = fileURL
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
                self?.performSegue(withIdentifier: "ShowVLCPlayerViewController", sender: videoFileURL)
                
                print(videoFileURL)
                print(videoFilePath)
            },
            failure: { [weak self] error in
                guard let self = self else { return }
                self.state = .failed(self.state, error)
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
        if case .readyForStream = state {
            state = .downloadTorrentFile
        } else if case .failed = state {
            state = .fetchTrackerInfo
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVLCPlayerViewController", let controller = segue.destination as? VLCPlayerViewConttroller {
            controller.videoFileURL = sender as? URL
            controller.onDismiss = { [weak self] in
                self?.state = .readyForStream
            }
        }
    }
}





