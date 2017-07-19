//
//  DayPickerView.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-19.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class DayPickerView: UIPickerView {
    let changeHandler: (Day) -> Void

    init(with day: Day, changeHandler: @escaping (Day) -> Void) {
        self.changeHandler = changeHandler

        super.init(frame: .zero)

        self.dataSource = self
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DayPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
}

extension DayPickerView: UIPickerViewDelegate {
    private func day(from picker: UIPickerView) -> Day {
        let dayRow = picker.selectedRow(inComponent: 0)

        return Day(rawValue: dayRow + 1)!
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Day(rawValue: row + 1)?.description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeHandler(day(from: pickerView))
    }
}
