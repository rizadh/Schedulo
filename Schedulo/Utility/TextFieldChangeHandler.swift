//
//  TextFieldChangeHandler.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-19.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class TextFieldChangeHandler {
    var handler: (UITextField) -> Void

    @objc func textFieldDidChange(_ textField: UITextField) {
        handler(textField)
    }

    init(_ handler: @escaping (UITextField) -> Void) {
        self.handler = handler
    }
}
