//
//  CourseDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-01.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CourseDetailViewController: UITableViewController {
    // MARK: - Private constants
    private struct Section {
        static let courses = 0
        static let sectionGrouping = 1

        private init() { }
    }

    // MARK: - Private Properties
    private let saveHandler: (Course) -> Void
    private var course: Course {
        didSet {
            self.saveButton.isEnabled = !course.code.isEmpty
        }
    }
    private let isNewCourse: Bool
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private var multipleSectionGroups: (isEnabled: Bool, switch: UISwitch?, groups: Set<SectionType>) = (false, nil, []) {
        didSet {
            let indexPath = IndexPath(row: 1, section: Section.sectionGrouping)

            switch (oldValue.isEnabled, multipleSectionGroups.isEnabled) {
            case (true, false):
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case (false, true):
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            default:
                break
            }
            multipleSectionGroups.switch?.isOn = multipleSectionGroups.isEnabled
        }
    }

    // MARK: - Private Methods
    @objc
    private func updateMultipleSectionGroups() {
        if let groupingSwitch = multipleSectionGroups.switch {
            multipleSectionGroups.isEnabled = groupingSwitch.isOn
        }
    }

    private func manageSectionGroups() {
        let controller = SectionTypeSelectorViewController {
            self.multipleSectionGroups.groups = $0
        }
        controller.sectionTypes = multipleSectionGroups.groups
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Public Properties
    var cancelHandler: (() -> Void)?

    // MARK: - Initializers
    init(for courseOrNil: Course? = nil, saveHandler: @escaping (Course) -> Void) {
        self.saveHandler = saveHandler
        if let course = courseOrNil {
            isNewCourse = false
            self.course = course
        } else {
            isNewCourse = true
            self.course = Course(code: "", sections: [:])
        }

        super.init(style: .grouped)

        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveCourse))
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))

        self.navigationItem.title = isNewCourse ? "New Course" : "Edit Course"
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton

        saveButton.isEnabled = !isNewCourse
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Button Handlers
    @objc
    private func saveCourse() {
        saveHandler(course)
        hideKeyboardAndDismiss()
    }

    @objc
    private func cancel() {
        cancelHandler?()
        hideKeyboardAndDismiss()
    }

    private func hideKeyboardAndDismiss() {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewController Overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.courses:
            return 1
        case Section.sectionGrouping:
            return multipleSectionGroups.isEnabled ? 2 : 1
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case Section.sectionGrouping:
            return "Enable this if your course offers more than one group of sections to choose from, e.g., one for lectures, another for tutorials. Generated schedules will contain one section from each group."
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.sectionGrouping:
            return "Section Grouping"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (Section.sectionGrouping, 1): manageSectionGroups()
        default: fatalError("Unrecognized index path")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (Section.courses, _):
            let cell = TextFieldCell { newCourseCode in
                self.course.code = newCourseCode
            }
            cell.textField.text = course.code
            cell.textField.placeholder = "Course Code"
            return cell
        case (Section.sectionGrouping, 0):
            let groupingSwitch = UISwitch()

            multipleSectionGroups.switch = groupingSwitch
            groupingSwitch.addTarget(self, action: #selector(updateMultipleSectionGroups), for: .valueChanged)

            let cell = UITableViewCell()
            cell.accessoryView = groupingSwitch
            cell.textLabel?.text = "Multiple Groups"
            return cell
        case (Section.sectionGrouping, 1):
            let cell = UITableViewCell()
            cell.textLabel?.text = "Manage"
            cell.accessoryType = .disclosureIndicator
            return cell
        default:
            fatalError("Unrecognized index path")
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (Section.courses, _):
            return false
        case (Section.sectionGrouping, 0):
            return false
        default:
            return true
        }
    }
}
