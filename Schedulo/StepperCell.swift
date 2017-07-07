//
//  StepperCell.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-27.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

protocol StepperCellDelegate {
    func valueDidChange(in stepperCell: StepperCell, to newValue: Double)
}

class StepperCell: UITableViewCell, UITextFieldDelegate {
    var delegate: StepperCellDelegate?
    
    var value: Int {
        get {
            return Int(stepper.value)
        }

        set {
            stepper.value = Double(newValue)
            textField.text = String(newValue)
        }
    }

    lazy var stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addTarget(self, action: #selector(self.handleChange), for: .valueChanged)
        return stepper
    }()

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.textColor = .lightGray
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        field.returnKeyType = .done
        field.text = "test"
        return field
    }()
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, let newValue = Int(text) {
            stepper.value = Double(newValue)
            handleChange()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    @objc func handleChange() {
        delegate?.valueDidChange(in: self, to: stepper.value)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.addSubview(stepper)
        contentView.addSubview(textField)

        let guide = contentView.layoutMarginsGuide

        textField.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        stepper.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16).isActive = true
        stepper.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        stepper.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
    }
}
