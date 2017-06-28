//
//  Section.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Section {
    let identifier: String
    let sessions: Set<Session>
}

extension Section: Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.sessions == rhs.sessions
    }
}

extension Section: Hashable {
    var hashValue: Int {
        return self.identifier.hashValue
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
