//
//  Day.swift
//  schedulerSwift
//
//  Created by Rizadh Nizam on 2017-06-20.
//
//

import Foundation

enum Day: Int, Codable {
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

extension Day: CustomStringConvertible {
    var description: String {
        switch (self) {
        case .Sunday: return "Sunday"
        case .Monday: return "Monday"
        case .Tuesday: return "Tuesday"
        case .Wednesday: return "Wednesday"
        case .Thursday: return "Thursday"
        case .Friday: return "Friday"
        case .Saturday: return "Saturday"
        }
    }
}

extension Day: Equatable {
    static func == (lhs: Day, rhs: Day) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Day: Comparable {
    static func < (lhs: Day, rhs: Day) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
