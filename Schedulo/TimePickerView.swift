//
//  TimePickerView.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-19.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class TimePickerView: UIPickerView {
    static let minTime = Time(hour: 0, minute: 0)
    static let maxTime = Time(hour: 23, minute: 50)
    static let minuteInterval = 10

    private let changeHandler: (Time) -> Void

    init(with time: Time, changeHandler: @escaping (Time) -> Void) {
        self.changeHandler = changeHandler

        super.init(frame: .zero)

        self.dataSource = self
        self.delegate = self

        select(time: time)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func select(time: Time, animated: Bool = false) {
        precondition(time.minute % 10 == 0, "Cannot set picker to a minute that is not a multiple of 10.")

        let hourRow = time.hour % 12
        let minuteRow = time.minute / 10
        let timeOfDayRow = time.hour < 12 ? 0 : 1

        self.selectRow(hourRow, inComponent: 0, animated: animated)
        self.selectRow(minuteRow, inComponent: 1, animated: animated)
        self.selectRow(timeOfDayRow, inComponent: 2, animated: animated)
    }
}


// MARK: - UIPickerViewDataSource Conformance
extension TimePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 12
        case 1:
            return 6
        case 2:
            return 2
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate Conformance
extension TimePickerView: UIPickerViewDelegate {
    private func hour(at row: Int) -> String? {
        switch row {
        case 0:
            return "12"
        case 1..<12:
            return String(row)
        default:
            return nil
        }
    }

    private func minute(at row: Int) -> String? {
        switch row {
        case 0:
            return "00"
        case 1..<6:
            return "\(row * 10)"
        default:
            return nil
        }
    }

    private func timeOfDay(at row: Int) -> String? {
        switch row {
        case 0:
            return "AM"
        case 1:
            return "PM"
        default:
            return nil
        }
    }

    private func time(from picker: UIPickerView) -> Time {
        let hourRow = picker.selectedRow(inComponent: 0)
        let minuteRow = picker.selectedRow(inComponent: 1)
        let timeOfDayRow = picker.selectedRow(inComponent: 2)

        let hour = hourRow + 12 * timeOfDayRow
        let minute = minuteRow * 10

        return Time(hour: hour, minute: minute)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return hour(at: row)
        case 1:
            return minute(at: row)
        case 2:
            return timeOfDay(at: row)
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeHandler(time(from: pickerView))
    }
}
