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
    let stateController: StateController

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

        self.updateStateBasedViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods


    private func updateStateBasedViews() {
        if stateController.courses.isEmpty {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else {
            self.navigationItem.setLeftBarButton(editButtonItem, animated: true)
        }
    }

    // MARK: Course Management
    @objc private func addCourse() {
        let courseIndex = self.stateController.courses.count
        let indexPath = IndexPath(row: courseIndex, section: 0)

        let courseItem = AutoSavingItem<Course>(with: nil) { courseOrNil in
            guard let course = courseOrNil else {
                if courseIndex < self.stateController.courses.count {
                    self.stateController.removeCourse(at: courseIndex)
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                }

                return
            }

            if courseIndex < self.stateController.courses.count {
                self.stateController.replaceCourse(at: courseIndex, with: course)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self.stateController.add(course)
                let indexPath = IndexPath(row: courseIndex, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .none)
            }
        }

        let courseDetailViewController = CourseDetailViewController(for: courseItem)

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    private func editCourse(at courseIndex: Int) {
        let existingCourse = stateController.courses[courseIndex]
        let indexPath = IndexPath(row: courseIndex, section: 0)
        var courseHasBeenDeleted = false

        let courseItem = AutoSavingItem<Course>(with: existingCourse) { courseOrNil in
            guard let course = courseOrNil else {
                self.stateController.removeCourse(at: courseIndex)
                self.tableView.deleteRows(at: [indexPath], with: .none)
                courseHasBeenDeleted = true

                return
            }

            if courseHasBeenDeleted {
                self.stateController.add(course, at: courseIndex)
                self.tableView.insertRows(at: [indexPath], with: .none)
            } else {
                self.stateController.replaceCourse(at: courseIndex, with: course)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }

            courseHasBeenDeleted = false
        }

        let courseDetailViewController = CourseDetailViewController(for: courseItem)

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    private func deleteCourse(at courseIndex: Int) {
        stateController.removeCourse(at: courseIndex)
        self.tableView.deleteRows(at: [IndexPath(row: courseIndex, section: 0)], with: .left)
    }

    // MARK: - UITableViewController Overrides
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            fatalError("Invalid section")
        }

        return stateController.courses.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        let cell = UITableViewCell()
        cell.textLabel!.text = stateController.courses[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        editCourse(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        switch editingStyle {
        case .delete:
            deleteCourse(at: indexPath.row)
        default:
            fatalError("Unsupported commit operation")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        return true
    }
}
