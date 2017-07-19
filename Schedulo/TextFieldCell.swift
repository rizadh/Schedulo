//
//  TextFieldCell.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-27.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    var changeHandler: (String) -> Void

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        return textField
    }()

    init(changeHandler: @escaping (String) -> Void) {
        self.changeHandler = changeHandler

        super.init(style: .default, reuseIdentifier: nil)

        textLabel!.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        changeHandler(textField.text!)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.addSubview(textField)

        let guide = contentView.layoutMarginsGuide

        textField.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
    }
}
