//
//  CourseDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-01.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

private extension String {
    var isValidCourseName: Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func isValidCourseName(in controller: CourseDetailViewController) -> Bool {
        guard self.isValidCourseName else {
            return false
        }

//        guard let coursesViewController = (controller.parent as? UINavigationController)?.viewControllers.first as? CoursesViewController else {
//            return false
//        }

        return false

//        for course in coursesViewController.stateController.courses {
//            if course == controller.course {
//                continue
//            }
//
//            if self.caseInsensitiveCompare(course.name) == .orderedSame {
//                return false
//            }
//        }

//        return true
    }

    private var isValidGroupName: Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func isValidGroupName(in controller: CourseDetailViewController) -> Bool {
        guard self.isValidGroupName else {
            return false
        }

        guard case .grouped(let groups) = controller.course.sections else {
            return true
        }

        for groupName in groups.keys {
            if self.caseInsensitiveCompare(groupName) == .orderedSame {
                return false
            }
        }

        return true
    }
}

private extension Array where Element: Hashable {
    func orderedByFrequency() -> [Element] {
        var frequencies = [Element: Int]()

        self.forEach {
            frequencies[$0] = (frequencies[$0] ?? 0) + 1
        }

        return frequencies.sorted { $0.value > $1.value }.map { $0.key }
    }
}

class CourseDetailViewController: UITableViewController {

    // MARK: - Static Private Properties

    static let possibleGroupNames = ["Lecture", "Practical", "Tutorial", "Lab"]

    // MARK: - Private Properties

    // MARK: Alert Handling
    private var textFieldChangeHandler: TextFieldChangeHandler!

    // MARK: Table Sections
    private struct TableSection {
        static let courseName = 0
        static let sections = 1
    }

    // MARK: TableCells
    var courseNameTextField: UITextField?

    // MARK: Course Properties
    private var courseItem: AutoSavingItem<Course>
    private var isNewCourse: Bool {
        return courseItem.isNewItem
    }
    var course = Course("") {
        didSet {
            if course.name.isValidCourseName {
                courseItem.value = course
            } else {
                courseItem.value = nil
            }

            switch (oldValue.sections, course.sections) {
            case (.ungrouped, .grouped(let newGroups)):
                let indexPaths = (1..<newGroups.keys.count + 2).map { IndexPath(row: $0, section: TableSection.sections) }
                tableView.beginUpdates()
                tableView.insertRows(at: indexPaths, with: .left)
                tableView.deleteRows(at: [IndexPath(row: 1, section: TableSection.sections)], with: .right)
                tableView.endUpdates()
            case (.grouped(let oldGroups), .ungrouped):
                let indexPaths = (1..<oldGroups.keys.count + 2).map { IndexPath(row: $0, section: TableSection.sections) }
                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .left)
                tableView.insertRows(at: [IndexPath(row: 1, section: TableSection.sections)], with: .right)
                tableView.endUpdates()
            default:
                break
            }
        }
    }
    private var sectionTypes: [String]? {
        switch course.sections {
        case .grouped(let groups):
            return groups.keys.sorted()
        case .ungrouped:
            return nil
        }
    }

    // MARK: Section Grouping
    private var sectionGroupingIsEnabled: Bool {
        switch course.sections {
        case .grouped:
            return true
        case .ungrouped:
            return false
        }
    }

    // MARK: - Initializers

    init(for courseItem: AutoSavingItem<Course>) {
        self.courseItem = courseItem
        if let course = courseItem.value {
            self.course = course
        }

        super.init(style: .grouped)

        self.navigationItem.title = isNewCourse ? "New Course" : "Edit Course"
        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    // MARK: Course Name Suggestions
    func parseCourseSuffix(_ name: String) -> [String] {
        let pattern = try! NSRegularExpression(pattern: "^[A-Za-z]+", options: [])
        guard let matchRange = pattern.firstMatch(in: name, options: [], range: NSRange(location: 0, length: name.count))?.range else {
            return []
        }

        var nameSuffix = String((name as NSString).substring(with: matchRange))

        var possibleSuffixes = [String]()

        repeat {
            possibleSuffixes.append(nameSuffix)
            nameSuffix.removeLast()
        } while (nameSuffix.count >= 3)

        return possibleSuffixes
    }

    func generateSuggestedCourseNames() -> [String] {
//        guard let coursesViewController = (self.parent as? UINavigationController)?.viewControllers.first as? CoursesViewController else {
//            return []
//        }

        return []

//        return coursesViewController.stateController.courses.flatMap { parseCourseSuffix($0.name) }.orderedByFrequency().filter { $0.isValidCourseName(in: self) }
    }

    // MARK: Section Grouping
    @objc private func toggleSectionGrouping() {
        self.setEditing(false, animated: true)

        switch course.sections {
        case .ungrouped(let sections):
            migrate(ungrouped: sections)
        case .grouped(let groups):
            migrate(grouped: groups)
        }
    }

    private func migrate(ungrouped sections: [Section]) {
        guard !sections.isEmpty else {
            course.sections = .grouped([:])
            return
        }

        let alertController = UIAlertController(title: "Enable Grouping", message: "You have existing ungrouped sections. They will be placed in a new group.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            (self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.accessoryView as! UISwitch).setOn(false, animated: true)
        }

        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            let groupName = alertController.textFields!.first!.text!
            self.course.sections = .grouped([groupName: sections])
        })

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            if let groupName = textField.text, groupName.isValidGroupName(in: self) {
                doneAction.isEnabled = true
            } else {
                doneAction.isEnabled = false
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter a new name for the group"
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words

            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler.textFieldDidChange(_:)), for: .allEditingEvents)

            let validNames = CourseDetailViewController.possibleGroupNames.filter { name in
                return name.isValidGroupName(in: self)
            }

            if !validNames.isEmpty {
                textField.inputAccessoryView = InputSuggestionView(with: validNames, suggestionHandler: { selectedOption in
                    textField.text = selectedOption
                    self.textFieldChangeHandler.textFieldDidChange(textField)
                })
            }
        })

        present(alertController, animated: true, completion: nil)
    }

    private func migrate(grouped groups: [String: [Section]]) {
        var sections = groups.values.flatMap { $0 }

        for sectionName in sections.map({ $0.name }) {
            var indexes = [Int]()

            for (index, sectionNameToMatch) in sections.map({ $0.name }).enumerated() {
                if sectionName.caseInsensitiveCompare(sectionNameToMatch) == .orderedSame {
                    indexes.append(index)
                }
            }

            indexes.sort()

            guard indexes.count > 1 else {
                continue
            }

            let combinedSessions = Set(indexes.flatMap { sections[$0].sessions })

            let combinedSection = Section(name: sectionName, sessions: Array(combinedSessions))

            for index in indexes.reversed() {
                sections.remove(at: index)
            }

            sections.append(combinedSection)
        }

        course.sections = .ungrouped(sections)
    }

    private func addSectionGroup() {
        func addGroup(named name: String) {
            guard case .grouped(var groups) = self.course.sections else {
                fatalError("Cannot add section group to ungrouped course.")
            }

            groups[name] = []
            self.course.sections = .grouped(groups)
            let newIndex = groups.keys.sorted().index(of: name)!

            self.tableView.insertRows(at: [IndexPath(row: newIndex + 1, section: TableSection.sections)], with: .top)
        }

        tableView.deselectRow(at: IndexPath(row: self.sectionTypes!.count + 1, section: TableSection.sections), animated: true)

        let alertController = UIAlertController(title: "Add Section Group", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            let groupName = alertController.textFields!.first!.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            guard groupName.isValidGroupName(in: self) else {
                self.addSectionGroup()
                return
            }

            addGroup(named: groupName)
        })

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            if let groupName = textField.text, groupName.isValidGroupName(in: self) {
                addAction.isEnabled = true
            } else {
                addAction.isEnabled = false
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter a new name for the group"
            textField.clearButtonMode = .always
            textField.autocapitalizationType = .words

            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler.textFieldDidChange(_:)), for: .allEditingEvents)

            let validNames = CourseDetailViewController.possibleGroupNames.filter { name in
                return name.isValidGroupName(in: self)
            }

            if !validNames.isEmpty {
                textField.inputAccessoryView = InputSuggestionView(with: validNames, suggestionHandler: { selectedOption in
                    textField.text = selectedOption
                    self.textFieldChangeHandler.textFieldDidChange(textField)
                })
            }
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

        let contoller = OldSectionsViewController(for: existingSections, saveHandler: saveHandler)
        contoller.sectionType = sectionTypeOrNil
        navigationController?.pushViewController(contoller, animated: true)
    }

    // MARK: - UIViewController Overrides

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !course.name.isValidCourseName(in: self) {
            courseNameTextField?.becomeFirstResponder()
        }
    }

    // MARK: - UITableViewController Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        return course.name.isValidCourseName(in: self) ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSection.courseName:
            return 1
        case TableSection.sections:
            if sectionGroupingIsEnabled {
                return sectionTypes!.count + 2
            } else {
                return 2
            }
        default:
            fatalError("Invalid section")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case TableSection.courseName:
            return "Course Name"
        case TableSection.sections:
            return "Sections"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (TableSection.courseName, 0):
            let cell = TextFieldCell {
                if $0.isValidCourseName(in: self) {
                    let oldCourseName = self.course.name
                    self.course.name = $0

                    if let textFieldCell = self.tableView.cellForRow(at: indexPath) as? TextFieldCell {
                        textFieldCell.textField.placeholder = $0
                    }

                    if !oldCourseName.isValidCourseName {
                        tableView.insertSections([TableSection.sections], with: .fade)
                    }
                } else {
                    if let textFieldCell = self.tableView.cellForRow(at: indexPath) as? TextFieldCell {
                        if self.course.name.isValidGroupName(in: self) {
                            textFieldCell.textField.text = self.course.name
                        } else {
                            textFieldCell.textField.text = nil
                        }
                    }
                }
            }
            cell.textField.text = course.name
            cell.textField.placeholder = course.name.isEmpty ? "e.g. AAAB01" : course.name

            let suggestedCourseNames = generateSuggestedCourseNames()

            if !course.name.isValidCourseName && !suggestedCourseNames.isEmpty {
                cell.textField.inputAccessoryView = InputSuggestionView(with: suggestedCourseNames) { selectedOption in
                    cell.textField.text = selectedOption
                }
            }

            courseNameTextField = cell.textField

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
            fatalError("Invalid index path")
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (TableSection.courseName, 0), (TableSection.sections, 0):
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == TableSection.sections else {
            return false
        }

        guard let sectionTypes = sectionTypes, !sectionTypes.isEmpty else {
            return false
        }

        return (1...sectionTypes.count).contains(indexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            fatalError("Unsupported commit.")
        }

        guard indexPath.section == TableSection.sections else {
            fatalError("Invalid section.")
        }

        guard case .grouped(var sectionGroups) = course.sections else {
            fatalError("Inconsistent state: Cannot delete any rows when section grouping is disabled.")
        }

        guard let sectionTypes = sectionTypes, !sectionTypes.isEmpty else {
            fatalError("Inconsistent state: Cannot delete any rows when no section groups are present.")
        }

        let sectionType = sectionTypes[indexPath.row - 1]
        sectionGroups.removeValue(forKey: sectionType)

        course.sections = .grouped(sectionGroups)
        tableView.deleteRows(at: [indexPath], with: .left)
    }
}
