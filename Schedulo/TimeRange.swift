//
//  TimeRange.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-13.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct TimeRange {
    var start: Time
    var end: Time

    init(from start: Time, to end: Time) {
        guard start < end else {
            fatalError("Time range start must be before time range end")
        }

        self.start = start
        self.end = end
    }

    var duration: Int {
        return end.minutes - start.minutes
    }
}

extension TimeRange: Equatable {
    static func == (lhs: TimeRange, rhs: TimeRange) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

extension TimeRange: Comparable {
    static func < (lhs: TimeRange, rhs: TimeRange) -> Bool {
        return lhs.start < rhs.start
    }
}

extension TimeRange: Overlappable {
    static func overlap(lhs: TimeRange, rhs: TimeRange) -> Bool {
        return (lhs.start < rhs.end) == (rhs.start < lhs.end)
    }
}
