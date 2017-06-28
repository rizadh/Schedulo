//
//  TextFieldCell.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-27.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate {
    func valueDidChange(in textFieldCell: TextFieldCell, to newValue: String?)
}

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    var delegate: TextFieldCellDelegate?

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.textAlignment = .right
        textField.autocapitalizationType = .words
        textField.adjustsFontSizeToFitWidth = true
        textField.delegate = self
        return textField
    }()

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.valueDidChange(in: self, to: textField.text)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.addSubview(textField)

        let guide = contentView.layoutMarginsGuide

        textField.trailingAnchor.constraint(equalTo: textLabel!.trailingAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
    }
}
