//
//  Course.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-15.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Course: Codable {
    var code: String
    var sections: [SectionType: [Section]]
    var allSections: [Section] {
        return sections.values.flatMap { $0 }
    }
}

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        guard lhs.code == rhs.code else {
            return false
        }

        // Can be replaced in Swift 4 with: lhs.sections == rhs.sections
        for (sectionType, lhsSections) in lhs.sections {
            guard let rhsSections = rhs.sections[sectionType] else {
                return false
            }

            guard lhsSections == rhsSections else {
                return false
            }
        }

        return true
    }
}

extension Course: Comparable {
    static func < (lhs: Course, rhs: Course) -> Bool {
        return lhs.code < rhs.code
    }
}

extension Course: Hashable {
    var hashValue: Int {
        return code.hashValue
    }
}
