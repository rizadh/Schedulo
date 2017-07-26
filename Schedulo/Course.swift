//
//  Course.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-15.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Course: Codable {
    var name: String
    var sections: Groupable<String, [Section]>
    var allSections: [Section] {
        switch sections {
        case .grouped(let groups):
            return groups.values.flatMap { $0 }
        case .ungrouped(let sections):
            return sections
        }
    }

    init(_ name: String, sections: Groupable<String, [Section]>) {
        self.name = name
        self.sections = sections
    }

    init(_ name: String) {
        self.init(name, withUngrouped: [])
    }

    init(_ name: String, withUngrouped sections: [Section]) {
        self.init(name, sections: .ungrouped(sections))
    }

    init(_ name: String, withGrouped sections: [String: [Section]]) {
        self.init(name, sections: .grouped(sections))
    }
}

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }

        switch (lhs.sections, rhs.sections) {
        case (.grouped(let lhsGroups), .grouped(let rhsGroups)):
            guard lhsGroups.keys == rhsGroups.keys else {
                return false
            }

            for sectionType in lhsGroups.keys {
                guard lhsGroups[sectionType]! == rhsGroups[sectionType]! else {
                    return false
                }
            }
        case (.ungrouped(let lhsSections), .ungrouped(let rhsSections)):
            guard lhsSections == rhsSections else {
                return false
            }
        default:
            return false
        }

        return true
    }
}

extension Course: Comparable {
    static func < (lhs: Course, rhs: Course) -> Bool {
        return lhs.name < rhs.name
    }
}

extension Course: Hashable {
    var hashValue: Int {
        return name.hashValue
    }
}
