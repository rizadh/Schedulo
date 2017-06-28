//
//  Overlappable.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-19.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

protocol Overlappable {
    static func overlap(lhs: Self, rhs: Self) -> Bool
}

extension Overlappable {
    func overlaps(with other: Self) -> Bool {
        return Self.overlap(lhs: self, rhs: other)
    }
}
