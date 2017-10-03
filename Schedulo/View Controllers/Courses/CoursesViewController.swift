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

    // MARK: - Initializers
    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        let addButtomItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCourse))

        self.navigationItem.title = "Courses"
        self.navigationItem.rightBarButtonItem = addButtomItem

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    // MARK: Course Management
    @objc private func addCourse() {
        let newCourse = Course("New Course")

        self.stateController.add(newCourse)

        let indexPath = IndexPath(row: self.stateController.courses.count - 1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func editCourse(at index: Int) {    }

    private func deleteCourse(at courseIndex: Int) {
        stateController.removeCourse(at: courseIndex)
        self.tableView.deleteRows(at: [IndexPath(row: courseIndex, section: 0)], with: .automatic)
    }
}

// MARK: - UITableViewController Method Overrides
extension CoursesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let course = stateController.courses[indexPath.row]

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = course.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editCourse(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            deleteCourse(at: indexPath.row)
        }
    }
}
