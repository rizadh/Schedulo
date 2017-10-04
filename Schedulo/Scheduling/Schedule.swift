//
//  Schedule.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-18.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    private(set) var selectedSections = [Course: Section]()

    static func getSchedules(for courses: [Course]) -> [Schedule] {
        return courses.reduce([Schedule()]) { (schedules, course) in
            schedules.flatMap() { schedule in
                course.sections.map { section in
                    var branchingSchedule = schedule
                    branchingSchedule.selectedSections[course] = section
                    return branchingSchedule
                }
            }
        }.filter { $0.isValid }
    }

    var sessions: [Session] {
        return sections.flatMap { $0.sessions }
    }

    var sections: [Section] {
        return selectedSections.flatMap { $0.value }
    }
}

// MARK: - Validity
extension Schedule {
    var isValid: Bool {
        for (outerIndex, outerSection) in sections.enumerated() {
            for (innerIndex, innerSection) in sections.enumerated() {
                if outerIndex == innerIndex {
                    continue
                }

                if outerSection.overlaps(with: innerSection) {
                    return false
                }
            }
        }

        return true
    }

}

// MARK: - Active Days
extension Schedule {
    var daysWithSessions: Set<Day> {
        return Set(sections.flatMap() { $0.sessions }.map() { $0.day })
    }
}

// MARK: - Time Gaps
extension Schedule {
    var timeGaps: [Day: Int] {
        var lastSessions = [Day: Session]()
        var gaps = [Day: Int]()

        for session in sessions.sorted(by: { $0.time < $1.time }) {
            if let lastSession = lastSessions[session.day] {
                let lastValue = gaps[session.day] ?? 0
                let delta = session.time.start.asMinutes - lastSession.time.end.asMinutes

                gaps[session.day] = lastValue + delta
            }

            lastSessions[session.day] = session
        }

        return gaps
    }

    var totalTimeGap: Int {
        return timeGaps.values.reduce(0, +)
    }

    var averageTimeGap: Int {
        return Int(totalTimeGap / daysWithSessions.count)
    }
}

// MARK: - Session Times
extension Schedule {
    var sessionTimes: [Day: Int] {
        var times = [Day: Int]()

        for session in sessions.sorted(by: { $0.time < $1.time }) {
            let lastValue = times[session.day] ?? 0
            let delta = session.time.duration

            times[session.day] = lastValue + delta
        }

        return times
    }

    var totalSessionTime: Int {
        return sessionTimes.values.reduce(0, +)
    }

    var averageSessionTime: Int {
        return Int(totalSessionTime / daysWithSessions.count)
    }
}

