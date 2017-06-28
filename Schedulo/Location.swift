//
//  Location.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-19.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Location {
    let building: String
    let room: Int
}

extension Location: Equatable {
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.building == rhs.building && lhs.room == rhs.room
    }
}
