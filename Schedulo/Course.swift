//
//  Course.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-15.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Course {
    var code: String
    var sections: Set<Section>
}

extension Course: Equatable {
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.code == rhs.code && lhs.sections == rhs.sections
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
