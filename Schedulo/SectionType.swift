//
//  SectionType.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-07.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

enum SectionType: CustomStringConvertible {
    case none
    case custom(name: String)

    static let suggested = [
        custom(name: "Lecture"),
        custom(name: "Tutorial"),
        custom(name: "Practical"),
        custom(name: "Lab")
    ]

    var description: String {
        switch self {
        case .custom(let name): return name
        case .none: return "None"
        }
    }
}

extension SectionType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else {
            let name = try container.decode(String.self)
            self = .custom(name: name)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .custom(let name): try container.encode(name)
        case .none: try container.encodeNil()
        }
    }
}

extension SectionType: Hashable {
    var hashValue: Int {
        switch self {
        case .custom(let name): return name.hashValue
        case .none: return "".hashValue
        }
    }

    static func ==(lhs: SectionType, rhs: SectionType) -> Bool {
        switch (lhs, rhs) {
        case (.custom(let lhsName), .custom(let rhsName)):
            return lhsName == rhsName
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
