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
    var stateController: StateController!

    // MARK: - Initializers
    init() {
        super.init(style: .plain)

        let addButtomItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCourse))

        navigationItem.title = "Courses"
        navigationItem.rightBarButtonItem = addButtomItem

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    // MARK: Course Management
    @objc private func addCourse() {
        let newCourse = Course("New Course")

        stateController.courses.append(newCourse)

        let indexPath = IndexPath(row: stateController.courses.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func editCourse(at index: Int) {
        let courseDetailViewController = CourseDetailViewController(style: .grouped)
        courseDetailViewController.stateController = stateController
        courseDetailViewController.courseIndex = index

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    private func deleteCourse(at courseIndex: Int) {
        stateController.courses.remove(at: courseIndex)
        tableView.deleteRows(at: [IndexPath(row: courseIndex, section: 0)], with: .automatic)
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
