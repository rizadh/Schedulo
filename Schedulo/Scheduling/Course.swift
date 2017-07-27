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
    var sectionGroups: [SectionGroup]
    var ungroupedSections: [Section] {
        return sectionGroups.flatMap { $0.sections }
    }

    init(_ name: String, sectionGroups: [SectionGroup]) {
        self.name = name
        self.sectionGroups = sectionGroups
    }

    init(_ name: String) {
        self.init(name, sectionGroups: [])
    }
}

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }

        guard lhs.sectionGroups == rhs.sectionGroups else {
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
