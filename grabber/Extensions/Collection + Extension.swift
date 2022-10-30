//
//  Collection + Extension.swift
//  grabber
//
//  Created by Stanislav Kaliberov on 30.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
