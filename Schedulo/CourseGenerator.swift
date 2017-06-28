//
//  CourseGenerator.swift
//  schedulerSwift
//
//  Created by Rizadh Nizam on 2017-06-19.
//
//

import Foundation

struct CourseGenerator {
    private static let INTERVAL_TIME = 30
    private static let FIRST_INTERVAL: UInt32 = 12
    private static let LAST_INTERVAL: UInt32 = 44
    private static let MIN_INTERVAL: UInt32 = 1
    private static let MAX_INTERVAL: UInt32 = 6

    static func generate(_ num: Int) -> [Course] {
        var courses = [Course]()

        while courses.count < num {
            courses.append(randomCourse(sectionsPerCourse: 3, sessionsPerSection: 3))
        }

        return courses
    }

    private static func randomCourse(sectionsPerCourse numSections: Int, sessionsPerSection numSessions: Int) -> Course {
        var sections = [Section]()

        while sections.count < numSections {
            sections.append(randomSection(sessionsPerSection: numSessions))
        }

        return Course(code: randomIdentifier(), sections: Set(sections))
    }

    private static func randomSection(sessionsPerSection numSessions: Int) -> Section {
        var sessions = [Session]()

        while sessions.count < numSessions {
            let newSession = randomSession()

            if !sessions.contains() { $0.overlaps(with: newSession) } {
                sessions.append(newSession)
            }
        }

        return Section(identifier: randomIdentifier(), sessions: Set(sessions))
    }

    private static func randomSession() -> Session {
        guard let day = Day(rawValue: 1 + Int(arc4random_uniform(5))) else {
            fatalError("Could not initialize a Day")
        }

        let intervals = generateIntervals()

        let startTime = getTime(for: intervals.start)
        let endTime = getTime(for: intervals.end)

        return Session(day: day, location: randomLocation(), time: TimeRange(from: startTime, to: endTime))
    }

    private static func randomLocation() -> Location {
        return Location(building: randomIdentifier(), room: Int(arc4random_uniform(UInt32(1e5))))
    }

    private static func generateIntervals() -> (start: Int, end: Int) {
        let numberOfIntervals = LAST_INTERVAL - FIRST_INTERVAL

        let startInterval = FIRST_INTERVAL + arc4random_uniform(numberOfIntervals - FIRST_INTERVAL - 1)
        let endInterval = MIN_INTERVAL + startInterval + arc4random_uniform(min(MAX_INTERVAL - MIN_INTERVAL, LAST_INTERVAL - startInterval))

        return (Int(startInterval), Int(endInterval))
    }

    private static func getTime(for interval: Int) -> Time {
        return Time(fromMinutes: interval * INTERVAL_TIME)
    }

    private static func randomIdentifier() -> String {
        var characters = [Character]()

        for _ in 1...5 {
            characters.append(randomCharacter())
        }

        return String(characters)
    }

    private static func randomCharacter() -> Character {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        let index = alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(26)))

        return alphabet[index]
    }
}
