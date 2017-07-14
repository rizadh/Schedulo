//
//  Time.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-12.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Time: Codable {
    static let maxHour = 23
    static let minHour = 0
    static let maxMinute = 59
    static let minMinute = 0

    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int) {
        guard hour >= Time.minHour else {
            fatalError("Cannot create a Time instance with an hour less than \(Time.minHour).")
        }

        guard hour <= Time.maxHour else {
            fatalError("Cannot create a Time instance with an hour greater than \(Time.maxHour)")
        }

        guard minute >= Time.minMinute else {
            fatalError("Cannot create a Time instance with a minute less than \(Time.minMinute).")
        }

        guard minute <= Time.maxMinute else {
            fatalError("Cannot create a Time instance with a minute greater than \(Time.maxMinute)")
        }

        self.hour = hour
        self.minute = minute
    }

    init(fromMinutes: Int) {
        guard fromMinutes > 0 else {
            fatalError("Cannot create a Time instance with negative minutes.")
        }

        guard fromMinutes < 24 * 60 else {
            fatalError("Cannot create a Time instance with more than 24 hours.")
        }

        var minutes = fromMinutes

        var hours = 0

        while minutes >= 60 {
            hours += 1
            minutes -= 60
        }

        self.hour = hours
        self.minute = minutes
    }

    var minutes: Int {
        return 60 * self.hour + self.minute
    }
}

extension Time: Equatable {
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.minutes == rhs.minutes
    }
}

extension Time: Comparable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.minutes < rhs.minutes
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
