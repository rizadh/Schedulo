//
//  Plan.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Plan: Codable {

    // MARK:- Public Properties

    var name: String
    var season: Season
    var year: Int
    var courses = [Course]() {
        didSet {
            schedules = Schedule.getSchedules(for: courses)
        }
    }

    private(set) var schedules = [Schedule]()

    // MARK: - Initializers

    init(_ name: String, in season: Season, _ year: Int) {
        self.name = name
        self.season = season
        self.year = year
    }

    init(for season: Season, _ year: Int) {
        self.name = "\(season) \(year)"
        self.season = season
        self.year = year
    }
}

// MARK: - CustomStringConvertible Conformance
extension Plan: CustomStringConvertible {
    var description: String {
        return schedules.map { schedule in
            "\(name) \(season) \(year):\n\(schedule)"
        }.joined(separator: "\n\n")
    }
}
