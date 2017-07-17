//
//  SessionDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-13.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SessionDetailViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Private Properties

    // MARK: Session Management
    private var session: Session {
        didSet {
            saveHandler(session)
        }
    }
    private let saveHandler: (Session) -> Void

    // MARK: Picker Visibility
    private var shouldDisplayDayPicker = false
    private var shouldDisplayStartTimePicker = false
    private var shouldDisplayEndTimePicker = false

    // MARK: Pickers
    private lazy var dayPicker: UIPickerView = {
        let picker = UIPickerView()

        picker.translatesAutoresizingMaskIntoConstraints = false

        picker.dataSource = self
        picker.delegate = self

        return picker
    }()

    private lazy var startTimePicker: UIPickerView = {
        let picker = UIPickerView()

        picker.translatesAutoresizingMaskIntoConstraints = false

        picker.dataSource = self
        picker.delegate = self

        return picker
    }()

    private lazy var endTimePicker: UIPickerView = {
        let picker = UIPickerView()

        picker.translatesAutoresizingMaskIntoConstraints = false

        picker.dataSource = self
        picker.delegate = self

        return picker
    }()

    // MARK: - Private Static Methods

    private static func generateSession() -> Session {
        let startTime = Time(hour: 6, minute: 0)
        let endTime = Time(hour: 7, minute: 0)

        let timeRange = TimeRange(from: startTime, to: endTime)

        return Session(day: .Wednesday, time: timeRange)
    }

    // MARK: - Initializers

    init(for sessionOrNil: Session?, saveHandler: @escaping (Session) -> Void) {
        let isNewSession: Bool

        if let session = sessionOrNil {
            isNewSession = false
            self.session = session
        } else {
            isNewSession = true
            self.session = SessionDetailViewController.generateSession()
        }

        self.saveHandler = saveHandler

        super.init(style: .grouped)

        self.navigationItem.title = isNewSession ? "New Session" : "Edit Session"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        let startHour = session.time.start.hour
        let startMinute = session.time.start.minute
        let endHour = session.time.end.hour
        let endMinute = session.time.end.minute

        dayPicker.selectRow(session.day.rawValue - 1, inComponent: 0, animated: false)

        if startHour < 12 {
            startTimePicker.selectRow(startHour, inComponent: 0, animated: false)
            startTimePicker.selectRow(0, inComponent: 2, animated: false)
        } else {
            startTimePicker.selectRow(startHour - 12, inComponent: 0, animated: false)
            startTimePicker.selectRow(1, inComponent: 2, animated: false)
        }

        startTimePicker.selectRow(startMinute, inComponent: 1, animated: false)

        if endHour < 12 {
            endTimePicker.selectRow(endHour, inComponent: 0, animated: false)
            endTimePicker.selectRow(0, inComponent: 2, animated: false)
        } else {
            endTimePicker.selectRow(endHour - 12, inComponent: 0, animated: false)
            endTimePicker.selectRow(1, inComponent: 2, animated: false)
        }

        endTimePicker.selectRow(endMinute, inComponent: 1, animated: false)
    }

    // MARK: - UITableViewContoller Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel!.text = "Day"
            cell.detailTextLabel!.text = "\(self.session.day)"
        case (0, 1):
            cell.contentView.addSubview(dayPicker)

            dayPicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            dayPicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            dayPicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            dayPicker.heightAnchor.constraint(equalToConstant: dayPicker.intrinsicContentSize.height).isActive = true
        case (1, 0):
            cell.textLabel!.text = "Start Time"
            cell.detailTextLabel!.text = "\(self.session.time.start)"
        case (1, 1):
            cell.contentView.addSubview(startTimePicker)

            startTimePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            startTimePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            startTimePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            startTimePicker.heightAnchor.constraint(equalToConstant: startTimePicker.intrinsicContentSize.height).isActive = true
        case (2, 0):
            cell.textLabel!.text = "End Time"
            cell.detailTextLabel!.text = "\(self.session.time.end)"
        case (2, 1):
            cell.contentView.addSubview(endTimePicker)

            endTimePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            endTimePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            endTimePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            endTimePicker.heightAnchor.constraint(equalToConstant: endTimePicker.intrinsicContentSize.height).isActive = true
        default:
            fatalError("Invalid index path.")
        }

        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row == 1 else {
            return UITableViewAutomaticDimension
        }

        switch indexPath.section {
        case 0:
            return shouldDisplayDayPicker ? dayPicker.intrinsicContentSize.height : 0
        case 1:
            return shouldDisplayStartTimePicker ? startTimePicker.intrinsicContentSize.height : 0
        case 2:
            return shouldDisplayEndTimePicker ? endTimePicker.intrinsicContentSize.height : 0
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row == 0 else {
            fatalError("Invalid row.")
        }

        switch indexPath.section {
        case 0:
            shouldDisplayDayPicker = !shouldDisplayDayPicker
            if shouldDisplayDayPicker {
                shouldDisplayStartTimePicker = false
                shouldDisplayEndTimePicker = false
            }
        case 1:
            shouldDisplayStartTimePicker = !shouldDisplayStartTimePicker
            if shouldDisplayStartTimePicker {
                shouldDisplayDayPicker = false
                shouldDisplayEndTimePicker = false
            }
        case 2:
            shouldDisplayEndTimePicker = !shouldDisplayEndTimePicker
            if shouldDisplayEndTimePicker {
                shouldDisplayDayPicker = false
                shouldDisplayStartTimePicker = false
            }
        default:
            fatalError("Invalid section.")
        }

        // Animate cell heights
        tableView.beginUpdates()
        tableView.endUpdates()

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UIPickerViewDataSource Methods

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case dayPicker:
            return 1
        case startTimePicker, endTimePicker:
            return 3
        default:
            fatalError("Invalid picker.")
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (pickerView, component) {
        case (dayPicker, 0):
            return 5
        case (startTimePicker, 0), (endTimePicker, 0):
            return 12
        case (startTimePicker, 1), (endTimePicker, 1):
            return 60
        case (startTimePicker, 2), (endTimePicker, 2):
            return 2
        default:
            fatalError("Invalid picker component.")
        }

    }

    // MARK: - UIPickerViewDelegate Methods

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch (pickerView, component) {
        case (dayPicker, 0):
            return Day(rawValue: row + 1)!.description
        case (startTimePicker, 0), (endTimePicker, 0):
            if row == 0 {
                return "12"
            }

            return String(row)
        case (startTimePicker, 1), (endTimePicker, 1):
            if row < 10 {
                return "0" + String(row)
            } else {
                return String(row)
            }
        case (startTimePicker, 2), (endTimePicker, 2):
            switch row {
            case 0:
                return "AM"
            case 1:
                return "PM"
            default:
                fatalError("Invalid picker row.")
            }
        default:
            fatalError("Invalid picker component.")
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var startTime = session.time.start
        var endTime = session.time.end

        switch (pickerView, component) {
        case (dayPicker, 0):
            session.day = Day(rawValue: row + 1)!
        case (startTimePicker, 0):
            if pickerView.selectedRow(inComponent: 2) == 0 {
                startTime.hour = row
            } else {
                startTime.hour = row + 12
            }
        case (endTimePicker, 0):
            if pickerView.selectedRow(inComponent: 2) == 0 {
                endTime.hour = row
            } else {
                endTime.hour = row + 12
            }
        case (startTimePicker, 1):
            startTime.minute = row
        case (endTimePicker, 1):
            endTime.minute = row
        case (startTimePicker, 2):
            let rawHour = pickerView.selectedRow(inComponent: 0)

            switch row {
            case 0:
                startTime.hour = rawHour
            case 1:
                startTime.hour = rawHour + 12
            default:
                fatalError("Invalid picker row.")
            }
        case (endTimePicker, 2):
            let rawHour = pickerView.selectedRow(inComponent: 0)

            switch row {
            case 0:
                endTime.hour = rawHour
            case 1:
                endTime.hour = rawHour + 12
            default:
                fatalError("Invalid picker row.")
            }
        default:
            fatalError("Invalid picker component.")
        }

        if startTime == Time(hour: Time.maxHour, minute: Time.maxMinute) {
            startTime = Time(hour: Time.maxHour, minute: Time.maxMinute - 1)
        }

        if endTime == Time(hour: Time.minHour, minute: Time.minMinute) {
            endTime = Time(hour: Time.minHour, minute: Time.minMinute + 1)
        }

        if startTime >= endTime {
            if startTime == session.time.start {
                if endTime.hour > Time.minHour {
                    startTime = Time(hour: endTime.hour - 1, minute: Time.minMinute)
                } else {
                    startTime = Time(hour: Time.minHour, minute: Time.minMinute)
                }
            }

            if endTime == session.time.end {
                if startTime.hour < Time.maxHour {
                    endTime = Time(hour: startTime.hour + 1, minute: Time.minMinute)
                } else {
                    endTime = Time(hour: Time.maxHour, minute: Time.maxMinute)
                }
            }
        }

        do {
            let startHour = startTime.hour
            let startMinute = startTime.minute

            if startHour < 12 {
                startTimePicker.selectRow(startHour, inComponent: 0, animated: true)
                startTimePicker.selectRow(0, inComponent: 2, animated: true)
            } else {
                startTimePicker.selectRow(startHour - 12, inComponent: 0, animated: true)
                startTimePicker.selectRow(1, inComponent: 2, animated: true)
            }

            startTimePicker.selectRow(startMinute, inComponent: 1, animated: true)
        }

        do {
            let endHour = endTime.hour
            let endMinute = endTime.minute

            if endHour < 12 {
                endTimePicker.selectRow(endHour, inComponent: 0, animated: true)
                endTimePicker.selectRow(0, inComponent: 2, animated: true)
            } else {
                endTimePicker.selectRow(endHour - 12, inComponent: 0, animated: true)
                endTimePicker.selectRow(1, inComponent: 2, animated: true)
            }

            endTimePicker.selectRow(endMinute, inComponent: 1, animated: true)
        }

        session.time = TimeRange(from: startTime, to: endTime)

        self.tableView.reloadRows(at: [
            IndexPath(row: 0, section: 0),
            IndexPath(row: 0, section: 1),
            IndexPath(row: 0, section: 2)
        ], with: .none)
    }
}
