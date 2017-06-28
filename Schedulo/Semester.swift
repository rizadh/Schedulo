//
//  Semester.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-24.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Semester {
    var label: String? {
        didSet {
            if label?.trimmingCharacters(in: .whitespaces) == "" { label = nil }
        }
    }
    var courses = Set<Course>()
    var year: Int {
        willSet {
            guard newValue >= 0 else {
                fatalError("Cannot set year to be less than 0 AD")
            }
        }
    }
    var season: Season

    var effectiveYear: Int {
        switch season {
        case .Fall:
            return year
        case .Winter, .Summer:
            return year - 1
        }
    }

    init(year: Int, season: Season, label: String? = nil) {
        self.year = year
        self.season = season
        self.label = label
    }
}

extension Semester: CustomStringConvertible {
    var description: String {
        return label ?? "\(season) \(year)"
    }
}

extension Semester: Equatable {
    static func == (lhs: Semester, rhs: Semester) -> Bool {
        return lhs.courses == rhs.courses && lhs.season == rhs.season && lhs.year == rhs.year && lhs.label == rhs.label
    }
}

extension Semester: Comparable {
    static func < (lhs: Semester, rhs: Semester) -> Bool {
        guard lhs.effectiveYear == rhs.effectiveYear else {
            return lhs.effectiveYear < rhs.effectiveYear
        }

        guard lhs.season == rhs.season else {
            return lhs.season < rhs.season
        }

        guard lhs.label == rhs.label else {
            return (lhs.label ?? "") < (rhs.label ?? "")
        }

        guard lhs.courses.count == rhs.courses.count else {
            return lhs.courses.count < rhs.courses.count
        }

        return false
    }
}

enum Season: String {
    case Fall, Winter, Summer

    static let all = [Fall, Winter, Summer]
}

extension Season: Equatable {
    static func == (lhs: Season, rhs: Season) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Season: Comparable {
    static func < (lhs: Season, rhs: Season) -> Bool {
        return Season.all.index(of: lhs)! < Season.all.index(of: rhs)!
    }
}
