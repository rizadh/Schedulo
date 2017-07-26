//
//  Keyable.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-12.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

enum Groupable<Key, Value> where Key: Hashable & Codable, Value: Codable {
    case grouped([Key: Value])
    case ungrouped(Value)
}

extension Groupable: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let groups = try? container.decode([Key: Value].self) {
            self = Groupable<Key, Value>.grouped(groups)
        }

        let sections = try container.decode(Value.self)
        self = .ungrouped(sections)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .grouped(let groups):
            try container.encode(groups)
        case .ungrouped(let sections):
            try container.encode(sections)
        }
    }
}