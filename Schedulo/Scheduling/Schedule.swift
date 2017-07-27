//
//  Schedule.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-18.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    private(set) var selectedSections = [Course: [String: Section]]()

    static func getSchedules(for courses: [Course]) -> [Schedule] {
        return courses.reduce([Schedule()]) { (schedules, course) in
            schedules.flatMap() { schedule in
                schedule.generateSchedules(adding: course)
            }
        }
    }

    private func generateSchedules(adding course: Course) -> [Schedule] {
        var schedules = [self]

        for (groupName, sections) in course.sectionGroups {
            schedules = schedules.flatMap { schedule in
                sections.map {
                    schedule.adding($0, from: groupName, in: course)
                }
            }.filter { $0.isValid }
        }

        return schedules
    }

    private mutating func add(_ section: Section, from groupName: String, in course: Course) {
        if var existingSections = selectedSections[course] {
            existingSections[groupName] = section
            selectedSections[course] = existingSections
        } else {
            selectedSections[course] = [groupName: section]
        }
    }

    private func adding(_ section: Section, from groupName: String, in course: Course) -> Schedule {
        var schedule = self
        schedule.add(section, from: groupName, in: course)
        return schedule
    }

    var sessions: [Session] {
        return sections.flatMap { $0.sessions }
    }

    var sections: [Section] {
        return selectedSections.values.flatMap { $0.values }
    }
}

// MARK: - Validity
extension Schedule {
    var isValid: Bool {
        for outerSection in sections {
            for innerSection in sections {
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

