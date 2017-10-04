//
//  PlanSeasonViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-04.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlanSeasonViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
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

        title = "Season"

        view.backgroundColor = .groupTableViewBackground

        let seasonPicker = UIPickerView()
        seasonPicker.translatesAutoresizingMaskIntoConstraints = false
        seasonPicker.dataSource = self
        seasonPicker.delegate = self

        seasonPicker.selectRow(Season.all.index(of: plan.season)!, inComponent: 0, animated: false)

        view.addSubview(seasonPicker)

        seasonPicker.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        seasonPicker.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        seasonPicker.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        seasonPicker.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Season.all[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        plan.season = Season.all[row]
    }
}
