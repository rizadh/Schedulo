//
//  Session.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Session: Codable {
    var day: Day
    var time: TimeRange
}

extension Session: Equatable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.day == rhs.day &&
        lhs.time == rhs.time
    }
}

extension Session: Comparable {
    static func < (lhs: Session, rhs: Session) -> Bool {
        guard lhs.day == rhs.day else {
            return lhs.day < rhs.day
        }

        return lhs.time < rhs.time
    }
}

extension Session: Hashable {
    var hashValue: Int {
        return self.day.hashValue
    }
}

extension Session: Overlappable {
    static func overlap(lhs: Session, rhs: Session) -> Bool {
        return lhs.day == rhs.day &&
        lhs.time.overlaps(with: rhs.time)
    }
}
