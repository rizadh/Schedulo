//
//  SectionGroup.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-27.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct SectionGroup: Codable {
    var name: String?
    var sections: [Section]
}

extension SectionGroup: Equatable {
    static func == (lhs: SectionGroup, rhs: SectionGroup) -> Bool {
        return lhs.name == rhs.name && lhs.sections == rhs.sections
    }
}
