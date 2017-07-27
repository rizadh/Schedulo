//
//  Time.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-12.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Time: Codable {
    private static let minHour = 0
    private static let maxHour = 24
    private static let minMinute = 0
    private static let maxMinute = 60

    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int) {
        guard hour >= Time.minHour else {
            fatalError("Hour must be at least \(Time.minHour)")
        }

        guard hour < Time.maxHour else {
            fatalError("Hour must be less than \(Time.maxHour)")
        }

        guard minute >= Time.minMinute else {
            fatalError("Minute must be at least \(Time.minMinute)")
        }

        guard minute < Time.maxMinute else {
            fatalError("Minute must be lower than \(Time.maxMinute)")
        }

        self.hour = hour
        self.minute = minute
    }

    static func fromMinutes(_ minutes: Int) -> Time {
        return Time(hour: minutes / 60, minute: minutes % 60)
    }

    var asMinutes: Int {
        return 60 * self.hour + self.minute
    }
}

extension Time: Equatable {
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.asMinutes == rhs.asMinutes
    }
}

extension Time: Comparable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.asMinutes < rhs.asMinutes
    }
}

extension Time: CustomStringConvertible {
    private enum TimeOfDay: String {
        case am = "AM"
        case pm = "PM"
    }

    private func hour24To12(_ hour: Int) -> (Int, TimeOfDay) {
        switch hour {
        case 0:
            return (12, .am)
        case 1..<12:
            return (hour, .am)
        case 12:
            return (hour, .pm)
        case 13...:
            return (hour - 12, .pm)
        default:
            fatalError("Invalid hour: \(hour)")
        }
    }

    var description: String {
        var descriptionString = ""

        let (parsedHour, timeOfDay) = hour24To12(hour)
        descriptionString += String(parsedHour)

        switch minute {
        case 0:
            break
        default:
            descriptionString += ":"

            if minute < 10 {
                descriptionString += "0"
            }

            descriptionString += String(minute)
        }

        descriptionString += " \(timeOfDay.rawValue)"

        return descriptionString
    }
}
