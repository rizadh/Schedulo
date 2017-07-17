//
//  Schedule.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-18.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    private(set) var selectedSections = [Course: Keyable<String, Section>]()

    static func getSchedules(for courses: [Course]) -> [Schedule] {
        return courses.reduce([Schedule()]) { (schedules, course) in
            schedules.flatMap() { schedule in
                schedule.generateSchedules(adding: course)
            }
        }
    }

    private func generateSchedules(adding course: Course) -> [Schedule] {
        var schedules = [self]

        switch course.sections {
        case .grouped(let groups):
            for (sectionType, sections) in groups {
                schedules = schedules.flatMap { schedule in
                    sections.map {
                        schedule.adding($0, ofType: sectionType, from: course)
                    }
                }.filter { $0.isValid }
            }
        case .ungrouped(let sections):
            schedules = schedules.flatMap { schedule in
                sections.map {
                    schedule.adding($0, ofType: nil, from: course)
                }
                }.filter { $0.isValid }
        }

        return schedules
    }

    private mutating func add(_ section: Section, ofType sectionTypeOrNil: String?, from course: Course) {
        guard let existing = selectedSections[course] else {
            if let sectionType = sectionTypeOrNil {
                selectedSections[course] = .grouped([sectionType: section])
            } else {
                selectedSections[course] = .ungrouped(section)
            }

            return
        }

        if let sectionType = sectionTypeOrNil {
            switch existing {
            case .grouped(var groups):
                groups.updateValue(section, forKey: sectionType)
                selectedSections[course] = .grouped(groups)
            case .ungrouped:
                fatalError("Cannot add a grouped section to a previously ungrouped course.")
            }
        } else {
            if case .grouped = existing {
                fatalError("Cannot add an ungrouped section to a previously grouped course.")
            }

            selectedSections[course] = .ungrouped(section)
        }
    }

    private func adding(_ section: Section, ofType sectionType: String?, from course: Course) -> Schedule {
        var schedule = self
        schedule.add(section, ofType: sectionType, from: course)
        return schedule
    }

    var sessions: [Session] {
        return sections.flatMap { $0.sessions }
    }

    var sections: [Section] {
        let sections: [[Section]] = selectedSections.values.map {
            switch $0 {
            case .grouped(let groups):
                return Array(groups.values)
            case .ungrouped(let section):
                return [section]
            }
        }

        return sections.flatMap { $0 }
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
//extension Schedule: CustomStringConvertible {
//    var description: String {
//        return courses.sorted { $0.key.code < $1.key.code }.flatMap { let (course, sections) = $0; return
//            sections.flatMap { $0.value.sessions }.map {
//                (course: course, session: $0)
//            }
//        }.map { let (course, session) = $0; return
//            "\(course.code): \(session.day) (\(session.time.start) - \(session.time.end))"
//        }.joined(separator: "\n")
//    }
//}

