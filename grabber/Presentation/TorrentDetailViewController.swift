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
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var videoControlButton: UIButton!
    
    var id: String!
    var torrentFileUrl: URL?
    
    private let api: RutrackerApiManager = RutrackerApiManager()
    private let streamer: PTTorrentStreamer = PTTorrentStreamer.shared()
    
    deinit {
        streamer.cancelStreamingAndDeleteData(true)
    }
    
    
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
                do {
                    let fileManager = FileManager.default
                    let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let fileURL = documentDirectory.appendingPathComponent(strongSelf.id)
                    let torrentFile = try result.get()
                    try torrentFile.write(to: fileURL)
                    strongSelf.torrentFileUrl = fileURL
                    
                } catch {
                    print(error)
                }
            }
        }
        
        fetchFile()
    }
    
    func play(fileUrl: URL) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVLCPlayerViewController", let controller = segue.destination as? VLCPlayerViewConttroller {
            controller.videoFileURL = sender as? URL
            controller.onDismiss = { [weak self] in
                self?.streamer.cancelStreamingAndDeleteData(true)
            }
        }
    }
}





