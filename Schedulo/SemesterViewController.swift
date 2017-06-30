//
//  SemesterViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-24.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SemesterViewController: UITableViewController {
    let TERM_SECTION = 0
    let COURSES_SECTION = 1

    let YEAR_ROW = 0
    let SEASON_ROW = 1
    let LABEL_ROW = 2

    var semester: Semester {
        didSet {
            updateSubviews()
            changeHandler(semester)
        }
    }

    let changeHandler: (Semester) -> Void

    var courses: [Course] {
        get {
            return semester.courses
        }

        set {
            semester.courses = newValue
        }
    }

    var selectedCourseIndex: Int!

    var originalSemester: Semester

    lazy var yearPicker: StepperCell = {
        let cell = StepperCell()

        cell.textLabel?.text = "Year"
        cell.stepper.minimumValue = 0
        cell.stepper.maximumValue = Double.infinity
        cell.selectionStyle = .none

        cell.delegate = self

        return cell
    }()

    lazy var seasonPicker: SegmentedControlCell = {
        let cell = SegmentedControlCell()

        cell.textLabel?.text = "Season"
        cell.selectionStyle = .none

        for (index, season) in Season.all.enumerated() {
            cell.control.insertSegment(withTitle: season.rawValue, at: index, animated: false)
        }

        cell.delegate = self

        return cell
    }()

    lazy var labelEditor: TextFieldCell = {
        let cell = TextFieldCell()

        cell.textLabel?.text = "Label"
        cell.textField.placeholder = "Optional"
        cell.selectionStyle = .none

        cell.delegate = self

        return cell
    }()

    init(for semester: Semester, changeHandler: @escaping (Semester) -> Void) {
        self.semester = semester
        self.originalSemester = semester
        self.changeHandler = changeHandler

        super.init(style: .grouped)

        updateSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    func addNewCourse() {
        let newCourse = Course(code: "", sections: [])

        semester.courses.append(newCourse)

        tableView.insertRows(at: [IndexPath(row: semester.courses.count - 1, section: COURSES_SECTION)], with: .automatic)

        editCourse(newCourse)
    }

    private func editCourse(_ course: Course) {
        selectedCourseIndex = courses.index(of: course)
        let controller = CourseViewController(for: course) { [unowned self] course in
            self.courses[self.selectedCourseIndex] = course
            self.selectedCourseIndex = self.courses.index(of: course)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    private func updateSubviews() {
        seasonPicker.control.selectedSegmentIndex = Season.all.index(of: semester.season)!
        labelEditor.textField.text = semester.label
        yearPicker.value = semester.year

        navigationItem.title = semester.description
    }

    func revertToOriginalSemester() {
        semester = originalSemester
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = semester.description
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(revertToOriginalSemester))
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case TERM_SECTION:
            return "Semester Information"
        case COURSES_SECTION:
            return "Courses"
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TERM_SECTION:
            return 3
        case COURSES_SECTION:
            return semester.courses.count + 1
        default:
            fatalError("Unrecognized section")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case TERM_SECTION:
            switch indexPath.row {
                case YEAR_ROW:
                    return yearPicker
                case SEASON_ROW:
                    return seasonPicker
                case LABEL_ROW:
                    return labelEditor
                default:
                    fatalError("Unrecognized row")
            }
        case COURSES_SECTION:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator

            if indexPath.row < semester.courses.count {
                let course = courses[indexPath.row]

                if course.code.isEmpty {
                    cell.textLabel?.text = "New Course"
                    cell.textLabel?.textColor = .lightGray
                } else {
                    cell.textLabel?.text = course.code
                    cell.detailTextLabel?.text = "\(course.sections.count) section"
                    if course.sections.count != 1 { cell.detailTextLabel?.text? += "s" }
                }
            } else {
                cell.textLabel?.text = "Add New Course"
            }
            return cell
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == COURSES_SECTION else {
            return
        }

        if indexPath.row < semester.courses.count {
            editCourse(courses[indexPath.row])
        } else {
            addNewCourse()
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == COURSES_SECTION else {
            fatalError("Can only delete from courses section")
        }

        switch editingStyle {
        case .delete:
            courses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            fatalError("Unsupported commit operation")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == COURSES_SECTION && indexPath.row < courses.count
    }
}

extension SemesterViewController: TextFieldCellDelegate {
    @nonobjc
    func valueDidChange(in textFieldCell: TextFieldCell, to newValue: String?) {
        semester.label = newValue
    }
}

extension SemesterViewController: StepperCellDelegate {
    @nonobjc
    func valueDidChange(in stepperCell: StepperCell, to newValue: Double) {
        semester.year = Int(newValue)
    }
}

extension SemesterViewController: SegmentedControlCellDelegate {
    @nonobjc
    func valueDidChange(in segmentedControlCell: SegmentedControlCell, to newValue: Int) {
        semester.season = Season.all[newValue]
    }
}
