//
//  Handler.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-17.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct AutoSavingItem<T> {
    var value: T? {
        didSet {
            changeHandler(value)
        }
    }

    var isNewItem: Bool {
        return originalValue == nil
    }

    let originalValue: T?
    private let changeHandler: (T?) -> Void

    init(with value: T?, changeHandler: @escaping (T?) -> Void) {
        self.value = value
        self.originalValue = value
        self.changeHandler = changeHandler
    }
}
