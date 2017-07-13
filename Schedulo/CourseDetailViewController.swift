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

            switch (oldValue.sections, course.sections) {
            case (.ungrouped, .grouped(let newGroups)):
                let indexPaths = (0...newGroups.keys.count).map { IndexPath(row: $0 + 1, section: TableSection.sections) }

                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: 1, section: TableSection.sections)], with: .fade)
                tableView.insertRows(at: indexPaths, with: .top)
                tableView.endUpdates()
            case (.grouped(let oldGroups), .ungrouped):
                let indexPaths = (0...oldGroups.keys.count).map { IndexPath(row: $0 + 1, section: TableSection.sections) }

                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .fade)
                tableView.insertRows(at: [IndexPath(row: 1, section: TableSection.sections)], with: .top)
                tableView.endUpdates()
                break
            default:
                break
            }
        }
    }
    private let isNewCourse: Bool
    private var sectionTypes: [String]? {
        switch course.sections {
        case .grouped(let groups):
            return groups.keys.sorted()
        case .ungrouped:
            return nil
        }
    }

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
        switch course.sections {
        case .ungrouped(let sections):
            migrate(ungrouped: sections)
        case .grouped(let groups):
            migrate(grouped: groups)
        }
    }

    private func migrate(ungrouped sections: [Section]) {
        if sections.isEmpty {
            course.sections = .grouped([:])
            return
        }

        let alertController = UIAlertController(title: "Enable Grouping", message: "You have \(sections.count) ungrouped course(s). Choose a new group name to store them or discard them if you wish to re-add all courses. The group name cannot be empty.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let discardAction = UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
            self.course.sections = .grouped([:])
        })
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { _ in
            let groupName = alertController.textFields!.first!.text!

            guard self.groupNameIsValid(groupName) else {
                self.migrate(ungrouped: sections)
                return
            }

            self.course.sections = .grouped([groupName: sections])
        })

        alertController.addAction(cancelAction)
        alertController.addAction(discardAction)
        alertController.addAction(continueAction)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "e.g. Lecture"
            textField.autocapitalizationType = .words
        })

        present(alertController, animated: true, completion: nil)
    }

    private func migrate(grouped groups: [String: [Section]]) {
        course.sections = .ungrouped(groups.values.flatMap({ $0 }))
    }

    private func groupNameIsValid(_ name: String, for groupIndexOrNil: Int? = nil) -> Bool {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }

        if let sectionTypes = sectionTypes {
            for (index, sectionType) in sectionTypes.enumerated() {
                if let groupIndex = groupIndexOrNil, groupIndex == index {
                    continue
                }

                if sectionType == name {
                    return false
                }
            }
        }

        return true
    }

    private func addSectionGroup() {
        tableView.deselectRow(at: IndexPath(row: self.sectionTypes!.count + 1, section: TableSection.sections), animated: true)

        let alertController = UIAlertController(title: "Add Section Group", message: "Choose a name for the new section group. The name must not be blank.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            let groupName = alertController.textFields!.first!.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            guard self.groupNameIsValid(groupName) else {
                self.addSectionGroup()
                return
            }

            guard case .grouped(var groups) = self.course.sections else {
                fatalError("Cannot add section group to ungrouped course.")
            }

            groups[groupName] = []
            self.course.sections = .grouped(groups)
            let newIndex = groups.keys.sorted().index(of: groupName)!

            self.tableView.insertRows(at: [IndexPath(row: newIndex + 1, section: TableSection.sections)], with: .top)
        })

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "e.g. Lecture"
            textField.autocapitalizationType = .words
        })

        present(alertController, animated: true, completion: nil)
    }

    // MARK: Section Management
    private func manageSections(for sectionTypeOrNil: String?) {
        let existingSections: [Section]
        let saveHandler: ([Section]) -> Void

        switch course.sections {
        case .grouped(var groups):
            guard let sectionType = sectionTypeOrNil else {
                fatalError("Did not pass a section type to a grouped course.")
            }

            existingSections = groups[sectionType]!
            saveHandler = {
                groups[sectionType] = $0
                self.course.sections = .grouped(groups)
                self.tableView.reloadSections([TableSection.sections], with: .none)
            }
        case .ungrouped(let sections):
            precondition(sectionTypeOrNil == nil, "Passed a section type to an ungrouped course.")

            existingSections = sections
            saveHandler = {
                self.course.sections = .ungrouped($0)
                self.tableView.reloadSections([TableSection.sections], with: .none)
            }
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
            if sectionGroupingIsEnabled {
                return sectionTypes!.count + 2
            } else {
                return 2
            }
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
            groupingSwitch.isOn = sectionGroupingIsEnabled
            groupingSwitch.addTarget(self, action: #selector(toggleSectionGrouping), for: .valueChanged)

            return cell
        case (TableSection.sections, (sectionTypes?.count ?? 0) + 1) where sectionGroupingIsEnabled:
            let cell = UITableViewCell()

            cell.textLabel!.text = "Add Group"
            cell.accessoryType = .disclosureIndicator

            return cell
        case (TableSection.sections, let row) where (1...).contains(row):
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

            cell.accessoryType = .disclosureIndicator

            let sectionCount: Int

            switch course.sections {
            case .grouped(let groups):
                let sectionType = sectionTypes![row - 1]
                sectionCount = groups[sectionTypes![row - 1]]!.count
                cell.textLabel!.text = "\(sectionType) Sections"
            case .ungrouped(let sections):
                sectionCount = sections.count
                cell.textLabel!.text = "Manage Sections"
            }

            switch sectionCount {
            case 1:
                cell.detailTextLabel!.text = "1 section"
            default:
                cell.detailTextLabel!.text = "\(sectionCount) sections"
            }

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
        case (TableSection.sections, (sectionTypes?.count ?? 0) + 1) where sectionGroupingIsEnabled:
            addSectionGroup()
        case (TableSection.sections, let row) where (1...).contains(row):
            manageSections(for: sectionTypes?[row - 1])
        default:
            break
        }
    }
}
