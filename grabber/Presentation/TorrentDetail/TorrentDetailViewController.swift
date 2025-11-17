//
//  TorrentDetailViewController.swift
//  grabber
//
//  Created by Станислав Калиберов on 10.02.2018.
//  Copyright © 2018 Станислав Калиберов. All rights reserved.
//

import UIKit
import Combine

class TorrentDetailViewController: UIViewController {
    @IBOutlet weak var bobodyTextViewdyLabel: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var videoControlButton: UIButton!

    var viewModel: TorrentDetailViewModel!
    private var cancellable: Set<AnyCancellable> = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$state.sink { [weak self] s in
            DispatchQueue.main.async {
                self?.render(state: s)
            }
        }.store(in: &cancellable)
        viewModel.viewDidLoad()
    }
    
    private func render(state: TorrentDetailViewModel.State) {
        switch state {
        case .initial:
            // initial setup ui
            break
            
        case .fetchTrackerInfo:
            activityIndicatorView.startAnimating()
            activityIndicatorView.isHidden = false
            
        case .readyForStream(let info):
            info.image.flatMap { ImageViewDownloader().perform(from: $0, imageView: self.backgroundImageView)}
            self.title = info.name
            self.bobodyTextViewdyLabel.text = info.body
            activityIndicatorView.isHidden = true
            
        case .downloadTorrentFile:
            activityIndicatorView.isHidden = false
            
        case .startStream:
            activityIndicatorView.isHidden = false
            
        case .needToSelectFileIndex(let files):
            activityIndicatorView.isHidden = true
            presentAlert(
                title: "Select file to play",
                items: files
                    .enumerated()
                    .map { i in (i.element, { _ in self.viewModel.selectTorrentFile(index: i.offset) }) }
                    .filter { !$0.0.hasSuffix(".srt") },
                cancel: { [weak self] _ in
                    self?.viewModel.returnToReadyForStream()
                }
            )
        case .streamingAndShowPlayer(videoFileURL: let videoFileURL):
            activityIndicatorView.isHidden = true
            performSegue(withIdentifier: C.showVLCPlayerSegueId, sender: videoFileURL)
            
        case .failed(let oldState, let error):
            activityIndicatorView.isHidden = true
            presentAlert(title: "Error", message: "\(error), for state \(oldState)")
        }
    }
    
    private func presentAlert(
        title: String,
        message: String? = nil,
        items: [(String, (UIAlertAction)->())] = [],
        cancel: ((UIAlertAction)->())? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        items
            .map { UIAlertAction(title: $0.0, style: .default, handler: $0.1)}
            .forEach(alert.addAction)
        if let cancel = cancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: cancel))
        }
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapVideoControlButton(_ sender: UIButton) {
        viewModel.playButtonDidTap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.showVLCPlayerSegueId, let controller = segue.destination as? VLCPlayerViewConttroller {
            controller.videoFileURL = sender as? URL
            controller.onDismiss = { [weak self] in
                self?.viewModel.returnToReadyForStream()
            }
        }
    }
}

extension TorrentDetailViewController {
    enum C {
        static let showVLCPlayerSegueId = "ShowVLCPlayerViewController"
    }
}
