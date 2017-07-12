//
//  CourseDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-01.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CourseDetailViewController: UITableViewController {

    // MARK: - Private Properties

    // MARK: Table Sections
    private struct TableSection {
        static let courseCode = 0
        static let sections = 1
    }

    // MARK: Course Properties
    private var course: Course {
        didSet {
            self.saveCourseItem.isEnabled = !course.code.isEmpty
            navigationItem.title = getNavigationTitle()

            tableView.reloadData()
        }
    }
    private let isNewCourse: Bool

    // MARK: Handlers
    private let saveHandler: (Course) -> Void
    private let cancelHandler: (() -> Void)?

    // MARK: Bar Buttons
    private var saveCourseItem: UIBarButtonItem!
    private var cancelItem: UIBarButtonItem!

    // MARK: Section Grouping
    private var sectionGroupingIsEnabled: Bool {
        switch course.sections {
        case .grouped:
            return true
        case .ungrouped:
            return false
        }
    }

    // MARK: - Private Methods

    private func getNavigationTitle() -> String {
        if !course.code.isEmpty {
            return course.code
        }

        if isNewCourse {
            return "New Course"
        }

        return "Edit Course"
    }

    // MARK: - Initializers

    init(for courseOrNil: Course?, saveHandler: @escaping (Course) -> Void, cancelHandler: (() -> Void)? = nil) {
        self.saveHandler = saveHandler
        self.cancelHandler = cancelHandler
        if let course = courseOrNil {
            isNewCourse = false
            self.course = course
        } else {
            isNewCourse = true
            self.course = Course(code: "", sections: .ungrouped([]))
        }

        super.init(style: .grouped)

        saveCourseItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveCourse))
        cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))

        self.navigationItem.title = getNavigationTitle()
        self.navigationItem.rightBarButtonItem = saveCourseItem
        self.navigationItem.leftBarButtonItem = cancelItem

        saveCourseItem.isEnabled = !isNewCourse
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Functions

    // MARK: Button Handlers
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

    // MARK: Section Grouping
    @objc
    private func toggleSectionGrouping() {
        print("Toggling section grouping")
    }

    // MARK: Section Management
    private func manageSections(for sectionTypeOrNil: String?) {
        let existingSections: [Section]
        let saveHandler: ([Section]) -> Void

        if case .grouped = course.sections {
            fatalError("Not supported yet")
        } else {
            precondition(sectionTypeOrNil == nil, "Passed a section type to an ungrouped course.")

            saveHandler = {
                self.course.sections = .ungrouped($0)
            }
        }

        switch course.sections {
        case .grouped:
            fatalError("Not supported yet.")
        case .ungrouped(let sections):
            existingSections = sections
        }

        let contoller = SectionsViewController(for: existingSections, saveHandler: saveHandler)
        navigationController?.pushViewController(contoller, animated: true)
    }

    // MARK: - UITableViewController Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSection.courseCode:
            return 1
        case TableSection.sections:
            return 2
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case TableSection.courseCode:
            return "Course Code"
        case TableSection.sections:
            return "Sections"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (TableSection.courseCode, 0):
            let cell = TextFieldCell { newCourseCode in
                self.course.code = newCourseCode
            }
            cell.textField.text = course.code
            cell.textField.placeholder = "e.g. AAAB01"
            return cell
        case (TableSection.sections, 0):
            let cell = UITableViewCell()
            let groupingSwitch = UISwitch()

            cell.accessoryView = groupingSwitch
            cell.textLabel?.text = "Group Sections"
            groupingSwitch.addTarget(self, action: #selector(toggleSectionGrouping), for: .valueChanged)

            return cell
        case (TableSection.sections, 1):
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

            cell.accessoryType = .disclosureIndicator
            cell.textLabel!.text = "Manage Sections"
            let sectionCount = course.allSections.count
            cell.detailTextLabel!.text = "\(course.allSections.count) section" + (sectionCount == 1 ? "" : "s")
            return cell
        default:
            fatalError("Unrecognized index path")
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (TableSection.courseCode, 0), (TableSection.sections, 0):
            return false
        default:
            return true
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (TableSection.sections, 1):
            manageSections(for: nil)
        default:
            break
        }
    }
}
