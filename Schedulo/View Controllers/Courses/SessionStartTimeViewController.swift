//
//  SessionStartTimeViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SessionStartTimeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
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

        title = "Start"

        view.backgroundColor = .groupTableViewBackground

        let timePicker = UIPickerView()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.dataSource = self
        timePicker.delegate = self

        timePicker.selectRow(session.time.start.hour, inComponent: 0, animated: false)
        timePicker.selectRow(session.time.start.minute, inComponent: 1, animated: false)

        view.addSubview(timePicker)

        timePicker.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        timePicker.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        timePicker.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        timePicker.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 24 : 60
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < 10 {
            return "0\(row)"
        } else {
            return "\(row)"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            session.time.start.hour = row
        } else {
            session.time.start.minute = row
        }
    }
}
