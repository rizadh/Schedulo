//
//  CoursesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CoursesViewController: UITableViewController {
    // MARK: - Private Properties
    private let stateController: StateController
    private var textFieldChangeHandler: TextFieldChangeHandler?

    // MARK: - Initializers
    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        let addButtomItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonItemHandler))

        self.navigationItem.title = "Courses"
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem = addButtomItem

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }

        self.updateStateBasedViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    // MARK: Course Name Validation
    private func courseCanBeNamed(_ courseName: String) -> Bool {
        return !courseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func courseExists(named courseName: String) -> Bool {
        return stateController.courses.map { $0.name }.contains(courseName)
    }

    private func newCourseCanBeCreated(named courseName: String) -> Bool {
        return courseCanBeNamed(courseName) && !courseExists(named: courseName)
    }

    // MARK: Course Name Suggestions
    private func parseCourseSuffix(_ name: String) -> [String] {
        let pattern = try! NSRegularExpression(pattern: "^([A-Za-z]+).+", options: [])
        guard let matchRange = pattern.firstMatch(in: name, options: [], range: NSRange(location: 0, length: name.count))?.range(at: 1) else {
            return []
        }

        var nameSuffix = String((name as NSString).substring(with: matchRange))

        var possibleSuffixes = [String]()

        while (nameSuffix.count >= 3) {
            possibleSuffixes.append(nameSuffix)
            nameSuffix.removeLast()
        }

        return possibleSuffixes
    }

    private func generateSuggestedCourseNames() -> [String] {
        return stateController.courses.map { $0.name }.flatMap(parseCourseSuffix).orderedByFrequency().filter(newCourseCanBeCreated)
    }

    // MARK: UI Updates
    private func updateStateBasedViews() {
        updateEditButtonItem()
    }

    private func updateEditButtonItem() {
        if stateController.courses.isEmpty {
            editButtonItem.isEnabled = false
        } else {
            editButtonItem.isEnabled = true
        }
    }

    // MARK: Button Handlers
    @objc private func addButtonItemHandler() {
        addCourse()
    }

    // MARK: Course Management
    private func addCourse() {
        let alertTitle = "New Course"
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let courseName = alertController.textFields?.first?.text else {
                return
            }

            let newCourse = Course(courseName)

            self.stateController.courses.append(newCourse)

            let indexPath = IndexPath(row: self.stateController.courses.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)

            self.updateStateBasedViews()
        })

        addAction.isEnabled = false

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            guard let courseName = textField.text else {
                addAction.isEnabled = false
                return
            }

            addAction.isEnabled = self.newCourseCanBeCreated(named: courseName)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { textField in
            textField.autocapitalizationType = .allCharacters
            textField.clearButtonMode = .always
            textField.placeholder = "Choose a name"

            let suggestedCourseNames = self.generateSuggestedCourseNames()
            if !suggestedCourseNames.isEmpty {
                textField.inputAccessoryView = InputSuggestionView(with: self.generateSuggestedCourseNames()) { selectedSuggestion in
                    textField.text = selectedSuggestion
                }
            }

            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler?.textFieldDidChange(_:)), for: .editingChanged)
        }

        present(alertController, animated: true, completion: nil)
    }

    private func renameCourse(at courseIndex: Int) {
        let alertTitle = "Rename Course"
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { _ in
            guard let newName = alertController.textFields?.first?.text else {
                return
            }

            self.stateController.courses[courseIndex].name = newName

            let indexPath = IndexPath(row: courseIndex, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)

            self.updateStateBasedViews()
        })

        renameAction.isEnabled = false

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            guard let courseName = textField.text else {
                renameAction.isEnabled = false
                return
            }

            renameAction.isEnabled = self.newCourseCanBeCreated(named: courseName)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(renameAction)
        alertController.addTextField { textField in
            textField.autocapitalizationType = .allCharacters
            textField.clearButtonMode = .always
            textField.placeholder = "Choose a new name"
            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler?.textFieldDidChange(_:)), for: .editingChanged)
        }

        present(alertController, animated: true, completion: nil)
    }

    private func editSectionsForCourse(at courseIndex: Int) {

    }

    private func deleteCourse(at courseIndex: Int) {
        stateController.removeCourse(at: courseIndex)
        self.tableView.deleteRows(at: [IndexPath(row: courseIndex, section: 0)], with: .left)

        updateStateBasedViews()
    }
}

// MARK: - UITableViewController Method Overrides
extension CoursesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.accessoryType = .detailDisclosureButton
        cell.textLabel?.text = stateController.courses[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        renameCourse(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editSectionsForCourse(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            deleteCourse(at: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Array Extensions
private extension Array where Element: Hashable {
    func orderedByFrequency() -> [Element] {
        var frequencies = [Element: Int]()

        self.forEach {
            frequencies[$0] = (frequencies[$0] ?? 0) + 1
        }

        return frequencies.sorted { $0.value > $1.value }.map { $0.key }
    }
}
