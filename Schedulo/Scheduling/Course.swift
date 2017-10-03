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
    var sections: [Section]

    init(_ name: String, sections: [Section]) {
        self.name = name
        self.sections = sections
    }

    init(_ name: String) {
        self.init(name, sections: [])
    }
}

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        return (lhs.name == rhs.name) && (lhs.sections == rhs.sections)
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
