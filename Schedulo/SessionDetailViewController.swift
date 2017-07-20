//
//  SessionDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-13.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SessionDetailViewController: UITableViewController {

    // MARK: Private Properties

    private var session: Session {
        didSet {
            saveHandler(session)
        }
    }

    private let saveHandler: (Session) -> Void

    private lazy var dayPicker: UIPickerView = {
        let picker = DayPickerView(with: session.day, changeHandler: self.setDay)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var startTimePicker: TimePickerView = {
        let picker = TimePickerView(with: session.time.start, changeHandler: self.setStartTime)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var endTimePicker: TimePickerView = {
        let picker = TimePickerView(with: session.time.end, changeHandler: self.setEndTime)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private var shouldDisplayDayPicker = false {
        didSet {
            switch (oldValue, shouldDisplayDayPicker) {
            case (false, true):
                expand(.day, .picker)
            case (true, false):
                collapse(.day, .picker)
            default:
                break
            }
        }
    }

    private var shouldDisplayStartTimePicker = false {
        didSet {
            switch (oldValue, shouldDisplayStartTimePicker) {
            case (false, true):
                expand(.startTime, .picker)
            case (true, false):
                collapse(.startTime, .picker)
            default:
                break
            }
        }
    }

    private var shouldDisplayEndTimePicker = false {
        didSet {
            switch (oldValue, shouldDisplayEndTimePicker) {
            case (false, true):
                expand(.endTime, .picker)
            case (true, false):
                collapse(.endTime, .picker)
            default:
                break
            }
        }
    }

    // MARK: Private Static Methods

    private static func generateSession() -> Session {
        let startTime = Time(hour: 9, minute: 0)
        let endTime = Time(hour: 11, minute: 0)

        let timeRange = TimeRange(from: startTime, to: endTime)

        return Session(day: .Wednesday, time: timeRange)
    }

    // MARK: Private Methods

    private func updateDisplays() {
        tableView.reloadRows(at: [
            indexPath(for: .day, .display),
            indexPath(for: .startTime, .display),
            indexPath(for: .endTime, .display)
        ], with: .none)
    }

    private func setDay(_ newDay: Day) {
        session.day = newDay

        updateDisplays()
    }

    private func setStartTime(_ newStartTime: Time) {
        if newStartTime < session.time.end {
            session.time.start = newStartTime
        } else if newStartTime == Time.maxTime {
            let adjustedStartTime = Time.fromMinutes(Time.maxTime.asMinutes - 1)
            session.time = TimeRange(from: adjustedStartTime, to: Time.maxTime)

            startTimePicker.select(time: adjustedStartTime, animated: true)
            endTimePicker.select(time: Time.maxTime)
        } else {
            while newStartTime >= session.time.end {
                if session.time.end.hour + 1 < Time.maxHour {
                    session.time.end.hour += 1
                } else if session.time.end.minute + 1 < Time.maxMinute {
                    session.time.end.minute += 1
                } else {
                    fatalError()
                }
            }

            session.time.start = newStartTime
            endTimePicker.select(time: session.time.end)
        }

        updateDisplays()
    }

    private func setEndTime(_ newEndTime: Time) {
        if session.time.start < newEndTime {
            session.time.end = newEndTime
        } else if newEndTime == Time.minTime {
            let adjustedEndTime = Time.fromMinutes(Time.minTime.asMinutes + 1)
            session.time = TimeRange(from: Time.minTime, to: adjustedEndTime)

            endTimePicker.select(time: adjustedEndTime, animated: true)
            startTimePicker.select(time: Time.minTime)
        } else {
            while session.time.start >= newEndTime {
                if session.time.start.hour > Time.minHour {
                    session.time.start.hour -= 1
                } else if session.time.start.minute > Time.minMinute {
                    session.time.start.minute -= 1
                } else {
                    fatalError()
                }
            }

            session.time.end = newEndTime
            startTimePicker.select(time: session.time.start)
        }

        updateDisplays()
    }

    private func expand(_ section: TableSection, _ row: TableRow) {
        self.tableView.insertRows(at: [indexPath(for: section, row)], with: .fade)
    }

    private func collapse(_ section: TableSection, _ row: TableRow) {
        self.tableView.deleteRows(at: [indexPath(for: section, row)], with: .fade)
    }

    // MARK: Initializers

    init(for sessionOrNil: Session?, saveHandler: @escaping (Session) -> Void) {
        let isNewSession: Bool

        if let session = sessionOrNil {
            isNewSession = false
            self.session = session
        } else {
            isNewSession = true
            self.session = SessionDetailViewController.generateSession()
            saveHandler(self.session)
        }

        self.saveHandler = saveHandler

        super.init(style: .grouped)

        self.navigationItem.title = isNewSession ? "New Session" : "Edit Session"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIViewController Overrides
extension SessionDetailViewController {
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
}

// MARK: - UITableViewController Overrides
extension SessionDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = tableSection(at: section) else {
            return 0
        }

        switch tableSection {
        case .day:
            return shouldDisplayDayPicker ? 2 : 1
        case .startTime:
            return shouldDisplayStartTimePicker ? 2 : 1
        case .endTime:
            return shouldDisplayEndTimePicker ? 2 : 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        let (sectionOrNil, rowOrNil) = tableSectionAndRow(for: indexPath)

        guard let section = sectionOrNil, let row = rowOrNil else {
            fatalError("Invalid index path.")
        }

        switch (section, row) {
        case (.day, .display):
            cell.textLabel!.text = "Day"
            cell.detailTextLabel!.text = "\(self.session.day)"
        case (.day, .picker):
            cell.contentView.addSubview(dayPicker)

            dayPicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            dayPicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            dayPicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            dayPicker.heightAnchor.constraint(equalToConstant: dayPicker.intrinsicContentSize.height).isActive = true
        case (.startTime, .display):
            cell.textLabel!.text = "Start Time"
            cell.detailTextLabel!.text = "\(self.session.time.start)"
        case (.startTime, .picker):
            cell.contentView.addSubview(startTimePicker)

            startTimePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            startTimePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            startTimePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            startTimePicker.heightAnchor.constraint(equalToConstant: startTimePicker.intrinsicContentSize.height).isActive = true
        case (.endTime, .display):
            cell.textLabel!.text = "End Time"
            cell.detailTextLabel!.text = "\(self.session.time.end)"
        case (.endTime, .picker):
            cell.contentView.addSubview(endTimePicker)

            endTimePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            endTimePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            endTimePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            endTimePicker.heightAnchor.constraint(equalToConstant: endTimePicker.intrinsicContentSize.height).isActive = true
        }

        // TODO: Remove this when row height animations are no longer used.
        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (sectionOrNil, rowOrNil) = tableSectionAndRow(for: indexPath)

        guard let section = sectionOrNil, let row = rowOrNil, row == .picker else {
            return UITableViewAutomaticDimension
        }

        switch section {
        case .day:
            return dayPicker.intrinsicContentSize.height
        case .startTime:
            return startTimePicker.intrinsicContentSize.height
        case .endTime:
            return endTimePicker.intrinsicContentSize.height
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (sectionOrNil, rowOrNil) = tableSectionAndRow(for: indexPath)

        guard let section = sectionOrNil, let _ = rowOrNil else {
            fatalError("Cannot select this index path.")
        }

        switch section {
        case .day:
            shouldDisplayDayPicker = !shouldDisplayDayPicker
            if shouldDisplayDayPicker {
                shouldDisplayStartTimePicker = false
                shouldDisplayEndTimePicker = false
            }
        case .startTime:
            shouldDisplayStartTimePicker = !shouldDisplayStartTimePicker
            if shouldDisplayStartTimePicker {
                shouldDisplayDayPicker = false
                shouldDisplayEndTimePicker = false
            }
        case .endTime:
            shouldDisplayEndTimePicker = !shouldDisplayEndTimePicker
            if shouldDisplayEndTimePicker {
                shouldDisplayDayPicker = false
                shouldDisplayStartTimePicker = false
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Table Cell Identification
extension SessionDetailViewController {
    private enum TableSection {
        case day
        case startTime
        case endTime
    }

    private enum TableRow {
        case display
        case picker
    }

    private func tableSection(at index: Int) -> TableSection? {
        switch index {
        case 0:
            return .day
        case 1:
            return .startTime
        case 2:
            return .endTime
        default:
            return nil
        }
    }

    private func tableRow(at index: Int) -> TableRow? {
        switch index {
        case 0:
            return .display
        case 1:
            return .picker
        default:
            return nil
        }
    }

    private func tableSectionAndRow(for indexPath: IndexPath) -> (section: TableSection?, row: TableRow?) {
        return (tableSection(at: indexPath.section), tableRow(at: indexPath.row))
    }

    private func indexPath(for section: TableSection, _ row: TableRow) -> IndexPath {
        let sectionIndex: Int
        let rowIndex: Int

        switch section {
        case .day:
            sectionIndex = 0
        case .startTime:
            sectionIndex = 1
        case .endTime:
            sectionIndex = 2
        }

        switch row {
        case .display:
            rowIndex = 0
        case .picker:
            rowIndex = 1
        }

        return IndexPath(row: rowIndex, section: sectionIndex)
    }
}
