//
//  PlanYearViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlanYearViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: State Management
    var stateController: StateController!
    var planIndex: Int!

    var plan: Plan {
        get {
            return stateController.plans[planIndex]
        }

        set {
            stateController.plans[planIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Year"

        view.backgroundColor = .groupTableViewBackground

        let yearPicker = UIPickerView()
        yearPicker.translatesAutoresizingMaskIntoConstraints = false
        yearPicker.dataSource = self
        yearPicker.delegate = self

        yearPicker.selectRow(plan.year - 2017, inComponent: 0, animated: false)

        view.addSubview(yearPicker)

        yearPicker.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        yearPicker.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        yearPicker.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        yearPicker.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(2017 + row)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        plan.year = 2017 + row
    }
}
