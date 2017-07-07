//
//  Season.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-28.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

enum Season: String, Codable {
    case Fall, Winter, Summer

    static let all = [Fall, Winter, Summer]
}

extension Season: Equatable {
    static func == (lhs: Season, rhs: Season) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Season: Comparable {
    static func < (lhs: Season, rhs: Season) -> Bool {
        return Season.all.index(of: lhs)! < Season.all.index(of: rhs)!
    }
}
