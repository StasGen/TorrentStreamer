//
//  ImageViewDownloader.swift
//  grabber
//
//  Created by Станислав К. on 14.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import UIKit

struct ImageViewDownloader {
    func perform(from url: URL, imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
