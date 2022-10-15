//
//  VLCPlayerViewConttroller.swift
//  grabber
//
//  Created by Stanislav Kaliberov on 15.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation
import UIKit
import MobileVLCKit

class VLCPlayerViewConttroller: UIViewController {
    @IBOutlet weak var playerView: UIView!
    
    private let mediaplayer = VLCMediaPlayer()
    var videoFileURL: URL?
    var onDismiss: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer.init(target: self, action: #selector(dismissPlayer))
        lpgr.minimumPressDuration = 2
        lpgr.delaysTouchesBegan = true
        
        playerView.addGestureRecognizer(lpgr)
        
        
        guard let videoFileURL = self.videoFileURL else {
            self.dismissPlayer()
            return
        }
        
        self.mediaplayer.delegate = self
        self.mediaplayer.drawable = self.playerView
        self.mediaplayer.media = VLCMedia(url: videoFileURL)
        self.mediaplayer.play()
        
    }
    
    @objc
    func dismissPlayer() {
        onDismiss?()
        dismiss(animated: true)
    }
}

extension VLCPlayerViewConttroller: VLCMediaPlayerDelegate {
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print("mediaPlayerStateChanged")
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        print("mediaPlayerTimeChanged")
    }
    
    func mediaPlayerTitleChanged(_ aNotification: Notification!) {
        print("mediaPlayerTitleChanged")
    }
    
    func mediaPlayerChapterChanged(_ aNotification: Notification!) {
        print("mediaPlayerChapterChanged")
    }
}
