//
//  SessionDayViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SessionDayViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: State Management
    var stateController: StateController!
    var courseIndex: Int!
    var sectionIndex: Int!
    var sessionIndex: Int!

    var session: Session {
        get {
            return stateController.courses[courseIndex].sections[sectionIndex].sessions[sessionIndex]
        }

        set {
            stateController.courses[courseIndex].sections[sectionIndex].sessions[sessionIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Day"

        view.backgroundColor = .groupTableViewBackground

        let dayPicker = UIPickerView()
        dayPicker.translatesAutoresizingMaskIntoConstraints = false
        dayPicker.dataSource = self
        dayPicker.delegate = self

        dayPicker.selectRow(session.day.rawValue - 1, inComponent: 0, animated: false)

        view.addSubview(dayPicker)

        dayPicker.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        dayPicker.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        dayPicker.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        dayPicker.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Day(rawValue: row + 1)!)"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        session.day = Day(rawValue: row + 1)!
    }
}
