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

enum Season: String {
    case Fall, Winter, Summer

    static let all = [Fall, Winter, Summer]
}
