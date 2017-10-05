//
//  Plan.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Plan: Codable {

    // MARK: - Public Properties

    var season: Season
    var year: Int
    var courses = [Course]() {
        didSet {
            schedules = Schedule.getSchedules(for: courses)
        }
    }

    private(set) var schedules = [Schedule]()

    // MARK: - Initializers

    init(for season: Season, _ year: Int) {
        self.season = season
        self.year = year
    }
}

extension Plan: CustomStringConvertible {
    var description: String {
        return "\(self.season) \(self.year)"
    }
}
