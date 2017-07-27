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
    var sectionGroups: [String: [Section]]
    var ungroupedSections: [Section] {
        return sectionGroups.values.flatMap { $0 }
    }
    var groupedSections: [String: [Section]] {
        return sectionGroups
    }

    init(_ name: String, sectionGroups: [String: [Section]]) {
        self.name = name
        self.sectionGroups = sectionGroups
    }

    init(_ name: String) {
        self.init(name, sectionGroups: [:])
    }
}

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        guard lhs.name == rhs.name else {
            return false
        }

        for groupName in lhs.sectionGroups.keys {
            guard let lhsSections = lhs.sectionGroups[groupName], let rhsSections = rhs.sectionGroups[groupName], lhsSections == rhsSections else {
                return false
            }
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
