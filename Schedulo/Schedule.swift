//
//  Schedule.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-18.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Schedule {
    private(set) var courses = [Course: Section]()

    static func getSchedules(for courses: [Course]) -> [Schedule] {
        var schedules = [Schedule()]

        for course in courses {
            schedules = schedules.map() { schedule in
                Array(schedule.generateSchedules(adding: course))
            }.flatMap() { $0 }
        }

        return schedules
    }

    private func generateSchedules(adding course: Course) -> Set<Schedule> {
        var schedules: Set = [self]

        for section in course.sections {
            var newCombination = self
            newCombination.add(section, from: course)
            if newCombination.isValid {
                schedules.insert(newCombination)
            }
        }

        return schedules
    }

    private mutating func add(_ section: Section, from course: Course) {
        guard course.sections.contains(section) else {
            fatalError("Section does not belong in course")
        }

        courses.updateValue(section, forKey: course)
    }

    var sessions: Set<Session> {
        return sections.reduce(Set<Session>(), {
            $0.union($1.sessions)
        })
    }

    var sections: Set<Section> {
        return Set(courses.map( { $0.value }))
    }
}

// MARK: - Validity
extension Schedule {
    var isValid: Bool {
        for outerSection in courses.values {
            for innerSection in courses.values {
                if (outerSection == innerSection) {
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
        var days = Set<Day>()

        for (_, section) in courses {
            for session in section.sessions {
                days.update(with: session.day)
            }
        }

        return days
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
                let delta = session.time.start.minutes - lastSession.time.end.minutes

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

// MARK: - CustomStringConvertible
extension Schedule: CustomStringConvertible {
    var description: String {
        var sessions = [String]()

        for (course, section) in courses.sorted(by: { $0.key.code < $1.key.code }) {
            for session in section.sessions {
                sessions.append("\(course.code): \(session.day) (\(session.time.start) - \(session.time.end))")
            }
        }

        return sessions.joined(separator: "\n")
    }
}

// MARK: - Equatable
extension Schedule: Equatable {
    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        return lhs.courses == rhs.courses
    }
}

// MARK: - Hashable
extension Schedule: Hashable {
    var hashValue: Int {
        var concatString = ""

        for (course, section) in courses {
            concatString += course.code + section.identifier
        }

        courses.keys.sorted(by: { $0.code < $1.code }).forEach({ course in
            concatString += course.code
            course.sections.sorted(by: { $0.identifier < $1.identifier }).forEach { section in
                concatString += section.identifier
            }
        })

        return concatString.hashValue
    }
}
