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

    var schedules = [Schedule]()
}
