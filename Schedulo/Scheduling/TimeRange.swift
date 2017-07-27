//
//  TimeRange.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-13.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct TimeRange: Codable {
    var start: Time {
        didSet {
            precondition(startIsBeforeEnd, "Start time must be before end time")
        }
    }
    var end: Time {
        didSet {
            precondition(startIsBeforeEnd, "Start time must be before end time")
        }
    }

    init(from start: Time, to end: Time) {
        self.start = start
        self.end = end

        precondition(startIsBeforeEnd, "Time range start must be before time range end")
    }

    var startIsBeforeEnd: Bool {
        return start < end
    }

    var duration: Int {
        return end.asMinutes - start.asMinutes
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
