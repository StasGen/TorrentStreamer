//
//  DetectUrlInString.swift
//  grabber
//
//  Created by Станислав К. on 13.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation

struct DetectUrlInString {
    func perform(string: String) -> [URL] {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            
            return matches.compactMap({ match in
                guard
                    let range = Range(match.range, in: string),
                    let url = URL(string: String(string[range]))
                else {
                    return nil
                }
                return url
            })
        } catch {
            return []
        }
    }
}

