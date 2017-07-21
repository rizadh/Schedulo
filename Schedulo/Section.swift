//
//  Section.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Section: Codable {
    var name: String
    var sessions: [Session]
}

extension Section: Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.name == rhs.name && lhs.sessions == rhs.sessions
    }
}

extension Section: Hashable {
    var hashValue: Int {
        return self.name.hashValue
    }
}

extension Section: Comparable {
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.name < rhs.name
    }
}

extension Section: Overlappable {
    static func overlap(lhs: Section, rhs: Section) -> Bool {
        for leftSession in lhs.sessions {
            for rightSession in rhs.sessions {
                if leftSession.overlaps(with: rightSession) {
                    return true
                }
            }
        }

        return false
    }
}
